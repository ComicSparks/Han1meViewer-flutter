import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/errors.dart';
import '../../core/net_settings.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/app.dart' as rapi;
import '../../src/rust/api/models.dart';
import '../../webview/web_auth.dart';
import '../../widgets/common.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({super.key});

  @override
  State<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends State<NetworkSettingsPage> {
  late NetSettings _s = rapi.netSettings();
  late final _mirror = TextEditingController(text: _s.customMirror);
  late final _hosts = TextEditingController(text: _s.customHosts);
  late final _dohUrl = TextEditingController(text: _s.dohCustomUrl);
  late final _dohBoot = TextEditingController(text: _s.dohBootstrapIps);
  late final _proxyHost = TextEditingController(text: _s.proxyHost);
  late final _proxyPort = TextEditingController(text: _s.proxyPort == 0 ? '' : '${_s.proxyPort}');
  IdentityInfo? _identity;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  @override
  void dispose() {
    for (final c in [_mirror, _hosts, _dohUrl, _dohBoot, _proxyHost, _proxyPort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadIdentity() async {
    final i = await rapi.identityInfo();
    if (mounted) setState(() => _identity = i);
  }

  void _update(NetSettings s) => setState(() {
        _s = s;
        _dirty = true;
      });

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    try {
      if (_hosts.text.trim().isNotEmpty) await rapi.validateIps(raw: _hosts.text);
      if (_dohBoot.text.trim().isNotEmpty) await rapi.validateIps(raw: _dohBoot.text);
      final s = _s.copyWith(
        customMirror: _mirror.text.trim(),
        customHosts: _hosts.text.trim(),
        dohCustomUrl: _dohUrl.text.trim(),
        dohBootstrapIps: _dohBoot.text.trim(),
        proxyHost: _proxyHost.text.trim(),
        proxyPort: int.tryParse(_proxyPort.text.trim()) ?? 0,
      );
      await rapi.setNetSettings(s: s);
      setState(() {
        _s = s;
        _dirty = false;
      });
      await _loadIdentity();
      if (mounted) toast(context, l.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _diagnose() async {
    final host = Uri.parse(rapi.baseUrl()).host;
    try {
      final ips = await rapi.dnsLookup(host: host);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(host),
          content: SelectableText(ips.isEmpty ? '-' : ips.join('\n')),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(AppLocalizations.of(context).ok))],
        ),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _manualImport() async {
    final l = AppLocalizations.of(context);
    final cf = TextEditingController();
    final ua = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.manualCfImport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.manualCfImportHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(controller: cf, decoration: const InputDecoration(labelText: 'cf_clearance')),
            TextField(controller: ua, maxLines: 3, decoration: const InputDecoration(labelText: 'User-Agent')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.ok)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await rapi.cfManualImport(cfClearance: cf.text, userAgent: ua.text);
      await _loadIdentity();
      if (mounted) toast(context, l.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
      );

  Widget _field(TextEditingController c, String label, {String? hint, int maxLines = 1, TextInputType? type}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: TextField(
          controller: c,
          maxLines: maxLines,
          keyboardType: type,
          onChanged: (_) => setState(() => _dirty = true),
          decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder(), isDense: true),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final id = _identity;
    final currentHost = Uri.tryParse(_s.domain)?.host ?? '';
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirm(context, l.discardChanges)) {
          setState(() => _dirty = false);
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.networkSettings),
          actions: [
            TextButton(onPressed: _dirty ? _save : null, child: Text(l.save)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _header(l.domain),
            RadioGroup<String>(
              groupValue: currentHost,
              onChanged: (h) => _update(_s.copyWith(domain: 'https://$h/')),
              child: Column(
                children: [
                  for (final h in hanimeHosts) RadioListTile<String>(value: h, title: Text(h), dense: true),
                ],
              ),
            ),
            SwitchListTile(
              title: Text(l.customMirror),
              value: _s.useCustomMirror,
              onChanged: (v) => _update(_s.copyWith(useCustomMirror: v)),
            ),
            if (_s.useCustomMirror) _field(_mirror, l.customMirror, hint: 'https://example.com/'),
            _header(l.dns),
            SwitchListTile(
              title: Text(l.builtInHosts),
              subtitle: Text(l.builtInHostsHint),
              value: _s.useBuiltInHosts,
              onChanged: (v) => _update(_s.copyWith(useBuiltInHosts: v)),
            ),
            if (_s.useBuiltInHosts) _field(_hosts, l.customIps, hint: '104.21.x.x, 172.67.x.x', maxLines: 2),
            SwitchListTile(
              title: const Text('DNS over HTTPS'),
              value: _s.useDoh,
              onChanged: (v) => _update(_s.copyWith(useDoh: v)),
            ),
            if (_s.useDoh) ...[
              ListTile(
                title: Text(l.dohServer),
                trailing: DropdownButton<String>(
                  value: dohPresets.contains(_s.dohPreset) ? _s.dohPreset : 'alidns',
                  items: [for (final p in dohPresets) DropdownMenuItem(value: p, child: Text(p))],
                  onChanged: (v) => _update(_s.copyWith(dohPreset: v)),
                ),
              ),
              if (_s.dohPreset == 'custom') ...[
                _field(_dohUrl, 'DoH URL', hint: 'https://dns.example/dns-query'),
                _field(_dohBoot, l.bootstrapIps, hint: '1.1.1.1, 8.8.8.8'),
              ],
              ListTile(
                title: Text(l.timeout),
                trailing: DropdownButton<int>(
                  value: _s.dohTimeoutSecs.clamp(2, 15),
                  items: [for (final t in [2, 3, 5, 8, 10, 15]) DropdownMenuItem(value: t, child: Text('${t}s'))],
                  onChanged: (v) => _update(_s.copyWith(dohTimeoutSecs: v)),
                ),
              ),
            ],
            ListTile(leading: const Icon(Icons.dns_outlined), title: Text(l.dnsDiagnose), onTap: _diagnose),
            _header(l.proxy),
            ListTile(
              title: Text(l.proxyMode),
              trailing: DropdownButton<String>(
                value: proxyModes.contains(_s.proxyMode) ? _s.proxyMode : 'system',
                items: [
                  DropdownMenuItem(value: 'system', child: Text(l.proxySystem)),
                  DropdownMenuItem(value: 'none', child: Text(l.proxyNone)),
                  const DropdownMenuItem(value: 'http', child: Text('HTTP')),
                  const DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
                ],
                onChanged: (v) => _update(_s.copyWith(proxyMode: v)),
              ),
            ),
            if (_s.proxyMode == 'http' || _s.proxyMode == 'socks5') ...[
              _field(_proxyHost, l.proxyHost, hint: '127.0.0.1'),
              _field(_proxyPort, l.proxyPort, hint: '7890', type: TextInputType.number),
            ],
            _header(l.identity),
            if (id != null) ...[
              ListTile(
                title: Text(l.deviceProfile),
                subtitle: Text('${id.profile.model} · Android ${id.profile.androidVersion} · Chrome ${id.profile.chromeMajor}'),
              ),
              ListTile(
                title: Text(l.currentUserAgent),
                subtitle: Text(id.effectiveUserAgent, style: Theme.of(context).textTheme.bodySmall),
                trailing: Chip(label: Text(id.followingWebview ? l.followingWebview : l.androidDisguise)),
                onLongPress: () => Clipboard.setData(ClipboardData(text: id.effectiveUserAgent)),
              ),
              ListTile(
                title: const Text('cf_clearance'),
                trailing: Icon(id.hasCfClearance ? Icons.check_circle : Icons.remove_circle_outline,
                    color: id.hasCfClearance ? Colors.green : null),
              ),
            ],
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l.verifyNow),
              subtitle: Text(l.verifyNowHint),
              enabled: WebAuth.available,
              onTap: () async {
                final ok = await WebAuth.verifyManually(context);
                await _loadIdentity();
                if (context.mounted) toast(context, ok ? l.verifySuccess : l.verifyCancelled);
              },
            ),
            ListTile(leading: const Icon(Icons.input), title: Text(l.manualCfImport), onTap: _manualImport),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(l.clearCf),
              onTap: () async {
                await rapi.cfClear();
                await _loadIdentity();
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino_outlined),
              title: Text(l.regenerateIdentity),
              subtitle: Text(l.regenerateIdentityHint),
              onTap: () async {
                if (!await confirm(context, l.regenerateIdentity, content: l.regenerateIdentityHint)) return;
                final i = await rapi.identityRegenerate();
                if (mounted) setState(() => _identity = i);
              },
            ),
          ],
        ),
      ),
    );
  }
}
