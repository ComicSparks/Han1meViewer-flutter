import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../src/rust/api/app.dart' as rapi;

class SearchOption {
  final Map<String, String> lang;
  final String? name;
  final String? key;
  const SearchOption({this.lang = const {}, this.name, this.key});

  factory SearchOption.fromJson(Map<String, dynamic> j) => SearchOption(
        lang: (j['lang'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? const {},
        name: j['name'] as String?,
        key: (j['search_key'] ?? j['reason_key']) as String?,
      );

  String label(Locale locale) {
    final code = switch (locale.languageCode) {
      'zh' => locale.countryCode == 'TW' ? 'zh-rTW' : 'zh-rCN',
      'ja' => 'ja',
      'en' => 'en',
      _ => 'en',
    };
    return lang[code] ?? lang['zh-rTW'] ?? name ?? key ?? '';
  }
}

class SearchOptions {
  final List<SearchOption> genre;
  final List<SearchOption> sort;
  final List<SearchOption> date;
  final List<SearchOption> duration;
  final Map<String, List<SearchOption>> tags;
  final List<SearchOption> brands;

  SearchOptions(this.genre, this.sort, this.date, this.duration, this.tags, this.brands);

  static SearchOptions? _cache;
  static String? _cacheGenreFile;

  /// 页面上的标签可能是任意语言的文案。站点筛选用的是 search_key（多为繁体）。
  static final Map<String, String> _searchKeys = {};

  static Future<List<SearchOption>> _list(String path) async {
    final raw = jsonDecode(await rootBundle.loadString(path)) as List;
    return raw.map((e) => SearchOption.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String get _genreFile =>
      rapi.netSettings().domain.contains('javchu') ? 'assets/search_options/genre_av.json' : 'assets/search_options/genre.json';

  static Future<SearchOptions> load() async {
    final gf = _genreFile;
    if (_cache != null && _cacheGenreFile == gf) return _cache!;
    final tagsRaw = jsonDecode(await rootBundle.loadString('assets/search_options/tags.json')) as Map<String, dynamic>;
    final tags = tagsRaw.map((k, v) => MapEntry(
          k,
          (v as List).map((e) => SearchOption.fromJson(e as Map<String, dynamic>)).toList(),
        ));
    _cache = SearchOptions(
      await _list(gf),
      await _list('assets/search_options/sort_option.json'),
      await _list('assets/search_options/release_date.json'),
      await _list('assets/search_options/duration.json'),
      tags,
      await _list('assets/search_options/brands.json'),
    );
    _cacheGenreFile = gf;
    _rebuildSearchKeys(_cache!);
    return _cache!;
  }

  /// 与原版 TagLocalizer.resolveSearchKey 相同：任意语言文案 → search_key，找不到则原样返回。
  static Future<String> resolveSearchKey(String tag) async {
    await load();
    return _searchKeys[tag] ?? tag;
  }

  static void _rebuildSearchKeys(SearchOptions options) {
    _searchKeys.clear();
    void add(SearchOption option) {
      final key = option.key;
      if (key == null || key.isEmpty) return;
      for (final raw in [key, option.name, ...option.lang.values]) {
        if (raw != null && raw.isNotEmpty) _searchKeys.putIfAbsent(raw, () => key);
      }
    }

    for (final list in options.tags.values) {
      for (final option in list) {
        add(option);
      }
    }
    for (final option in options.genre) {
      add(option);
    }
  }

  static Future<List<SearchOption>> reportReasons() => _list('assets/report_reason.json');
}
