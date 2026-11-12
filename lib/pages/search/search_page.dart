import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/errors.dart';
import '../../core/nav.dart';
import '../../core/search_options.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/local.dart' as local;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';

class SearchFilter {
  String? genre;
  String? sort;
  String? date;
  String? duration;
  bool broad = false;
  Set<String> tags = {};
  Set<String> brands = {};

  bool get isEmpty =>
      genre == null && sort == null && date == null && duration == null && tags.isEmpty && brands.isEmpty && !broad;

  int get count =>
      [genre, sort, date, duration].where((e) => e != null).length + tags.length + brands.length + (broad ? 1 : 0);

  SearchFilter copy() => SearchFilter()
    ..genre = genre
    ..sort = sort
    ..date = date
    ..duration = duration
    ..broad = broad
    ..tags = {...tags}
    ..brands = {...brands};
}

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final String? initialRawQuery;
  final List<String> initialTags;

  const SearchPage({super.key, this.initialQuery, this.initialRawQuery, this.initialTags = const []});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  SearchFilter _filter = SearchFilter();
  String? _rawQuery;
  int _searchId = 0;
  bool _searched = false;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    final query = widget.initialQuery?.trim();
    final raw = widget.initialRawQuery;
    if (query != null && query.isNotEmpty) _text.text = query;
    if (raw != null && raw.isNotEmpty) _rawQuery = raw;
    if (widget.initialTags.isNotEmpty) _filter.tags = widget.initialTags.toSet();
    _searched = _rawQuery != null || _filter.tags.isNotEmpty || _text.text.trim().isNotEmpty;
    _loadHistory();
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final h = await local.searchHistoryList();
      if (mounted) setState(() => _history = h);
    } catch (_) {}
  }

  void _run({bool saveHistory = true}) {
    _focus.unfocus();
    final q = _text.text.trim();
    if (saveHistory && q.isNotEmpty) {
      local.searchHistoryAdd(query: q).then((_) => _loadHistory());
    }
    setState(() {
      _searched = true;
      _searchId++;
    });
  }

  Future<PageResult> _loader(int page) {
    final raw = _rawQuery;
    if (raw != null) return hanime.searchRaw(queryString: raw, page: page);
    final q = _text.text.trim();
    return hanime.search(
      params: SearchParams(
        page: page,
        query: q.isEmpty ? null : q,
        genre: _filter.genre,
        sort: _filter.sort,
        broad: _filter.broad,
        date: _filter.date,
        duration: _filter.duration,
        tags: _filter.tags.toList(),
        brands: _filter.brands.toList(),
      ),
    );
  }

  Future<void> _openFilter() async {
    final r = await showModalBottomSheet<SearchFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FilterSheet(initial: _filter),
    );
    if (r == null) return;
    _filter = r;
    _rawQuery = null;
    _run(saveHistory: false);
  }

  Future<void> _pasteLink() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final code = data?.text == null ? null : hanime.parseVideoCode(text: data!.text!);
    if (!mounted) return;
    if (code == null) {
      toast(context, AppLocalizations.of(context).noLinkInClipboard);
    } else {
      openVideo(context, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = _filter.count + (_rawQuery != null ? 1 : 0);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          controller: _text,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            _rawQuery = null;
            _run();
          },
          decoration: InputDecoration(
            hintText: l.searchHint,
            isDense: true,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _text.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _text.clear()),
                  ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(tooltip: l.pasteLink, icon: const Icon(Icons.content_paste_go), onPressed: _pasteLink),
          IconButton(
            tooltip: l.filter,
            icon: Badge(isLabelVisible: count > 0, label: Text('$count'), child: const Icon(Icons.tune)),
            onPressed: _openFilter,
          ),
        ],
      ),
      body: !_searched
          ? _historyView(l)
          : PagedVideoGrid(key: ValueKey(_searchId), loader: _loader),
    );
  }

  Widget _historyView(AppLocalizations l) {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.searchEmptyHint),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: () => _run(saveHistory: false), child: Text(l.browseAll)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: Text(l.searchHistory, style: Theme.of(context).textTheme.titleSmall)),
            TextButton(
              onPressed: () async {
                await local.searchHistoryClear();
                _loadHistory();
              },
              child: Text(l.clear),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in _history)
              InputChip(
                label: Text(h),
                onPressed: () {
                  _text.text = h;
                  _rawQuery = null;
                  _run();
                },
                onDeleted: () async {
                  await local.searchHistoryDelete(query: h);
                  _loadHistory();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class FilterSheet extends StatefulWidget {
  final SearchFilter initial;
  const FilterSheet({super.key, required this.initial});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late SearchFilter _f = widget.initial.copy();
  SearchOptions? _opts;

  @override
  void initState() {
    super.initState();
    SearchOptions.load().then((o) {
      if (mounted) setState(() => _opts = o);
    });
  }

  String _catTitle(AppLocalizations l, String key) => switch (key) {
        'video_attributes' => l.tagVideoAttributes,
        'character_relationships' => l.tagRelationships,
        'characteristics' => l.tagCharacteristics,
        'appearance_and_figure' => l.tagAppearance,
        'story_location' => l.tagLocation,
        'story_plot' => l.tagPlot,
        'sex_positions' => l.tagPositions,
        _ => key,
      };

  Widget _single(String title, List<SearchOption> opts, String? value, ValueChanged<String?> onChanged) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final o in opts)
              ChoiceChip(
                label: Text(o.label(locale)),
                selected: value == o.key || (value == null && o.key == null),
                onSelected: (_) => setState(() => onChanged(o.key)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _multi(String title, List<SearchOption> opts, Set<String> values) {
    final locale = Localizations.localeOf(context);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: values.isEmpty
          ? null
          : Text(
              opts.where((o) => values.contains(o.key)).map((o) => o.label(locale)).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      initiallyExpanded: false,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final o in opts)
              if (o.key != null)
                FilterChip(
                  label: Text(o.label(locale)),
                  selected: values.contains(o.key),
                  onSelected: (v) => setState(() => v ? values.add(o.key!) : values.remove(o.key)),
                ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final o = _opts;
    if (o == null) return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _single(l.genre, o.genre, _f.genre, (v) => _f.genre = v),
                _single(l.sort, o.sort, _f.sort, (v) => _f.sort = v),
                _single(l.releaseDate, o.date, _f.date, (v) => _f.date = v),
                _single(l.duration, o.duration, _f.duration, (v) => _f.duration = v),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.broadMatch),
                  subtitle: Text(l.broadMatchHint),
                  value: _f.broad,
                  onChanged: (v) => setState(() => _f.broad = v),
                ),
                for (final e in o.tags.entries) _multi(_catTitle(l, e.key), e.value, _f.tags),
                _multi(l.brands, o.brands, _f.brands),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _f = SearchFilter()),
                      child: Text(l.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _f),
                      child: Text(l.apply),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
