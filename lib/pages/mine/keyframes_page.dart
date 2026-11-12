import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/keyframes.dart';
import '../../core/nav.dart';
import '../../core/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/local.dart' as local;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';

class KeyframesPage extends StatefulWidget {
  const KeyframesPage({super.key});

  @override
  State<KeyframesPage> createState() => _KeyframesPageState();
}

class _KeyframesPageState extends State<KeyframesPage> {
  List<HKeyframes>? _mine;
  List<HKeyframes>? _shared;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await local.keyframesList();
    final s = await KeyframeStore.allShared();
    if (mounted) {
      setState(() {
        _mine = m;
        _shared = s;
      });
    }
  }

  Widget _list(List<HKeyframes>? items, {required bool editable}) {
    final l = AppLocalizations.of(context);
    if (items == null) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return EmptyView(text: l.keyframesEmptyHint);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final k = items[i];
        return ListTile(
          title: Text(k.title.isEmpty ? k.videoCode : k.title),
          subtitle: Text([
            l.keyframeCount(k.keyframes.length),
            if (k.author != null) k.author!,
          ].join(' · ')),
          onTap: () => openVideo(context, k.videoCode),
          trailing: editable
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (!await confirm(context, l.delete, content: k.title)) return;
                    await local.keyframesDelete(videoCode: k.videoCode);
                    _load();
                  },
                )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.hKeyframes),
          bottom: TabBar(tabs: [Tab(text: l.localKeyframes), Tab(text: l.sharedKeyframes), Tab(text: l.settings)]),
        ),
        body: TabBarView(
          children: [
            _list(_mine, editable: true),
            _list(_shared, editable: false),
            SignalBuilder(
              builder: (context) => ListView(
                children: [
                  SwitchListTile(
                    title: Text(l.enableKeyframes),
                    subtitle: Text(l.enableKeyframesHint),
                    value: Prefs.hKeyframesEnabled.signal.value,
                    onChanged: (v) => Prefs.hKeyframesEnabled.value = v,
                  ),
                  SwitchListTile(
                    title: Text(l.sharedKeyframes),
                    value: Prefs.sharedKeyframesEnabled.signal.value,
                    onChanged: (v) => Prefs.sharedKeyframesEnabled.value = v,
                  ),
                  SwitchListTile(
                    title: Text(l.sharedKeyframesFirst),
                    value: Prefs.sharedKeyframesFirst.signal.value,
                    onChanged: (v) => Prefs.sharedKeyframesFirst.value = v,
                  ),
                  SwitchListTile(
                    title: Text(l.keyframeShowPrompt),
                    value: Prefs.keyframeShowPrompt.signal.value,
                    onChanged: (v) => Prefs.keyframeShowPrompt.value = v,
                  ),
                  ListTile(
                    title: Text(l.keyframeCountdown),
                    subtitle: Slider(
                      value: Prefs.keyframeCountdownSec.signal.value.toDouble(),
                      min: 3,
                      max: 30,
                      divisions: 27,
                      label: '${Prefs.keyframeCountdownSec.signal.value}s',
                      onChanged: (v) => Prefs.keyframeCountdownSec.value = v.round(),
                    ),
                    trailing: Text('${Prefs.keyframeCountdownSec.signal.value}s'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
