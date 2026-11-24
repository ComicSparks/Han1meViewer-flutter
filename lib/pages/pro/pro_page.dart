import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/errors.dart';
import '../../core/metrics.dart';
import '../../core/nav.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/pro.dart' as api;
import '../../widgets/common.dart';
import '../login_page.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  api.ProInfoAll? _info;
  String _server = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    Session.refresh();
    final info = api.proInfo();
    final server = api.proServerName();
    if (!mounted) return;
    setState(() {
      _info = info;
      _server = server;
    });
  }

  Future<bool> _ensureLogin() async {
    if (Session.loggedIn) return true;
    final ok = await push<bool>(context, const LoginPage());
    if (ok == true) {
      Session.refresh();
      return true;
    }
    return false;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    toast(context, l.proPleaseWait);
    try {
      await action();
      if (!mounted) return;
      toast(context, l.proSynced);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _load();
      }
    }
  }

  Future<void> _redeem() async {
    if (!await _ensureLogin() || !mounted) return;
    final code = await inputText(
      context,
      AppLocalizations.of(context).proEnterCode,
    );
    if (code == null || code.trim().isEmpty || !mounted) return;
    await _run(() async {
      await api.inputCdKey(cdKey: code.trim());
      Metrics.note('pro');
    });
  }

  Future<void> _enterKey() async {
    final key = await inputText(
      context,
      AppLocalizations.of(context).proEnterAuthCode,
    );
    if (key == null || key.trim().isEmpty || !mounted) return;
    await _run(() => api.setPatAccessKey(accessKey: key.trim()));
  }

  Future<void> _pickServer() async {
    final l = AppLocalizations.of(context);
    final ids = api.proServerIds();
    final picked = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l.proChooseMethod),
        children: [
          for (final id in ids)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, id),
              child: Text(
                id,
                style: TextStyle(
                  fontWeight: id == _server ? FontWeight.w600 : null,
                ),
              ),
            ),
        ],
      ),
    );
    if (picked == null || picked == _server) return;
    try {
      api.setProServerName(name: picked);
      setState(() => _server = picked);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _patMenu() async {
    final l = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l.proUpdatePat),
              onTap: () => Navigator.pop(c, 'update'),
            ),
            ListTile(
              title: Text(l.proBindAccount),
              onTap: () => Navigator.pop(c, 'bind'),
            ),
            ListTile(
              title: Text(l.proChangePatKey),
              onTap: () => Navigator.pop(c, 'key'),
            ),
            ListTile(
              title: Text(l.proClearPat),
              onTap: () => Navigator.pop(c, 'clear'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'update':
        await _run(api.reloadPatAccount);
      case 'bind':
        if (!await _ensureLogin() || !mounted) return;
        await _run(() async {
          await api.bindThisAccount();
          Metrics.note('pro');
          await api.reloadPatAccount();
        });
      case 'key':
        await _enterKey();
      case 'clear':
        if (!await confirm(context, l.proClearPat) || !mounted) return;
        try {
          api.clearPat();
          _load();
          toast(context, l.proSynced);
        } catch (e) {
          if (mounted) showError(context, e);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final info = _info;
    final af = info?.proInfoAf;
    final pat = info?.proInfoPat;
    final powered = (af?.isPro ?? false) || (pat?.isPro ?? false);
    final size = MediaQuery.sizeOf(context);
    final min = size.width < size.height ? size.width : size.height;
    return Scaffold(
      appBar: AppBar(title: Text(l.proCenter)),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          SizedBox(
            height: min / 3,
            child: Center(
              child: Icon(
                powered ? Icons.offline_bolt : Icons.offline_bolt_outlined,
                size: min / 5,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          SignalBuilder(
            builder: (context) {
              final s = Session.state.value;
              final name = s.username ?? '';
              final label = s.loggedIn ? (name.isEmpty ? '-' : name) : l.notLoggedIn;
              return Center(child: Text(label));
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(20), child: Text(l.proGuide)),
          const Divider(height: 1),
          ListTile(
            title: Text(l.proSignIn),
            subtitle: Text(
              af != null && af.isPro
                  ? '${l.proPowered} (${_time(af.expire)})'
                  : l.proNotPowered,
            ),
          ),
          ListTile(
            title: Text(l.proPatreon),
            subtitle: Text(
              pat != null && pat.isPro ? l.proPowered : l.proNotPowered,
            ),
            onTap: () => toast(context, l.proClickPatToChange),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(l.proIHavePowered),
            enabled: !_busy,
            onTap: () async {
              if (!await _ensureLogin()) return;
              await _run(api.reloadPro);
            },
          ),
          ListTile(
            title: Text(l.proIJustPowered),
            enabled: !_busy,
            onTap: _redeem,
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(l.proPowerMethod),
            subtitle: Text(_server),
            onTap: _pickServer,
          ),
          const Divider(height: 1),
          if (pat != null && pat.accessKey.isNotEmpty)
            ListTile(
              title: Text(l.proPatreon),
              subtitle: _patDetail(l, pat),
              enabled: !_busy,
              onTap: _patMenu,
            )
          else
            ListTile(
              title: Text(l.proPatreon),
              subtitle: Text(l.proClickToBind),
              enabled: !_busy,
              onTap: _enterKey,
            ),
          const Divider(height: 1),
          const _ReferralTiles(),
        ],
      ),
    );
  }

  Widget _patDetail(AppLocalizations l, api.ProInfoPat pat) {
    final username = Session.state.value.username ?? '';
    final lines = <String>[l.proKeyRecorded];
    if (pat.patId.isNotEmpty) lines.add('${l.proPatAccount}: ${pat.patId}');
    if (pat.bindUid.isNotEmpty) {
      lines.add('${l.proBoundAccount}: ${pat.bindUid}');
    }
    final boundAt = _time(pat.requestDelete);
    if (boundAt.isNotEmpty) lines.add('${l.proBindTime}: $boundAt');
    final rebindAt = _time(pat.reBind);
    if (rebindAt.isNotEmpty) lines.add('${l.proRebindTime}: $rebindAt');
    final hint = pat.bindUid.isEmpty
        ? l.proPatBindHint
        : pat.bindUid != username
        ? l.proPatRebindHint
        : !pat.isPro
        ? l.proPatNotDetected
        : l.proPatNormal;
    final color = pat.bindUid.isEmpty
        ? Colors.blue
        : pat.bindUid != username
        ? Theme.of(context).colorScheme.error
        : !pat.isPro
        ? Colors.orange
        : Colors.green;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: lines.join('\n')),
          TextSpan(
            text: '\n($hint)',
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

String _time(Object secs) {
  final n = secs is int ? secs : int.parse(secs.toString());
  if (n <= 0) return '';
  final d = DateTime.fromMillisecondsSinceEpoch(
    n * 1000,
    isUtc: true,
  ).toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

class _ReferralTiles extends StatefulWidget {
  const _ReferralTiles();

  @override
  State<_ReferralTiles> createState() => _ReferralTilesState();
}

class _ReferralTilesState extends State<_ReferralTiles> {
  bool _busy = false;
  String _referrer = '';
  int _unbindWaitDays = 0;
  int _campaignStart = 0;
  int _campaignEnd = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await api.referralCall(payload: '{"action":"local"}');
      if (!mounted || raw.isEmpty) return;
      _apply(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _referral(String payload, String ok) async {
    setState(() => _busy = true);
    try {
      final raw = await api.referralCall(payload: payload);
      if (!mounted) return;
      if (raw.isNotEmpty) {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
      }
      toast(context, ok);
    } catch (e) {
      if (mounted) toast(context, _referralError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _apply(Map<String, dynamic> map) {
    setState(() {
      _referrer = (map['referrer'] ?? '').toString();
      _unbindWaitDays = _asInt(map['unbind_wait_days']);
      _campaignStart = _asInt(map['campaign_start']);
      _campaignEnd = _asInt(map['campaign_end']);
    });
  }

  String _copy(Map<String, String> text) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh' &&
        (locale.scriptCode == 'Hant' || locale.countryCode == 'TW' || locale.countryCode == 'HK')) {
      return text['zh_TW'] ?? text['zh']!;
    }
    return text[locale.languageCode] ?? text['en'] ?? text['zh']!;
  }

  String _referralError(Object error) {
    final text = error.toString();
    final wait = RegExp(r'REFERRER_UNBIND_WAIT:(\d+)').firstMatch(text);
    if (wait != null) {
      return _copy(const {
        'zh': '还有 {days} 天',
        'zh_TW': '還有 {days} 天',
        'en': '{days} days left',
        'ja': 'あと {days} 日',
      }).replaceAll('{days}', wait.group(1)!);
    }
    if (text.contains('REFERRER_SELF')) {
      return _copy(const {'zh': '不能填写自己', 'zh_TW': '不能填寫自己', 'en': 'Cannot use yourself', 'ja': '自分は指定できません'});
    }
    if (text.contains('REFERRER_LOCKED')) {
      return _copy(const {'zh': '已经绑定了推荐人', 'zh_TW': '已經綁定了推薦人', 'en': 'Already bound', 'ja': 'すでに登録済みです'});
    }
    if (text.contains('REFERRER_MUTUAL')) {
      return _copy(const {'zh': '不能互相绑定', 'zh_TW': '不能互相綁定', 'en': 'Cannot bind each other', 'ja': '相互登録はできません'});
    }
    if (text.contains('REFERRER_NOT_BOUND')) {
      return _copy(const {'zh': '还没有推荐人', 'zh_TW': '還沒有推薦人', 'en': 'No referrer yet', 'ja': '紹介者はいません'});
    }
    return text;
  }

  Future<bool> _ensureLogin() async {
    if (Session.loggedIn) return true;
    final ok = await push<bool>(context, const LoginPage());
    if (ok == true) {
      Session.refresh();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final campaign = _campaignStart > 0 && _campaignEnd > 0
        ? '${_time(_campaignStart)} — ${_time(_campaignEnd)}'
        : '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(_copy(const {'zh': '推荐人', 'zh_TW': '推薦人', 'en': 'Referrer', 'ja': '紹介者'})),
          subtitle: Text(_referrer),
          enabled: !_busy,
          onTap: () async {
            if (!await _ensureLogin() || !context.mounted) return;
            if (_referrer.isNotEmpty) return;
            final name = await inputText(
              context,
              _copy(const {
                'zh': '填写推荐人用户名',
                'zh_TW': '填寫推薦人用戶名',
                'en': 'Enter referrer username',
                'ja': '紹介者のユーザー名',
              }),
            );
            if (name == null || name.trim().isEmpty) return;
            await _referral(
              jsonEncode({'action': 'bind', 'referrer': name.trim()}),
              _copy(const {'zh': '已绑定', 'zh_TW': '已綁定', 'en': 'Bound', 'ja': '登録しました'}),
            );
          },
          onLongPress: () async {
            if (_referrer.isEmpty) return;
            if (_unbindWaitDays > 0) {
              toast(context, _referralError('REFERRER_UNBIND_WAIT:$_unbindWaitDays'));
              return;
            }
            final ok = await confirm(
              context,
              _copy(const {'zh': '解绑推荐人', 'zh_TW': '解綁推薦人', 'en': 'Unbind referrer', 'ja': '紹介者を解除'}),
              content: _copy(const {
                'zh': '确定解绑推荐人？',
                'zh_TW': '確定解綁推薦人？',
                'en': 'Unbind this referrer?',
                'ja': '紹介者を解除しますか？',
              }),
            );
            if (!ok || !context.mounted) return;
            await _referral(
              '{"action":"unbind"}',
              _copy(const {'zh': '已解绑', 'zh_TW': '已解綁', 'en': 'Unbound', 'ja': '解除しました'}),
            );
          },
        ),
        ListTile(
          title: Text(_copy(const {'zh': '活动时间', 'zh_TW': '活動時間', 'en': 'Campaign time', 'ja': '活動期間'})),
          subtitle: Text(campaign),
        ),
      ],
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
