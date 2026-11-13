import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/app_update.dart';
import '../../core/errors.dart';
import '../../core/nav.dart';
import '../../core/prefs.dart';
import '../../core/pro.dart';
import '../../l10n/gen/app_localizations.dart';
import '../pro/pro_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((p) {
      if (mounted) setState(() => _version = '${p.version} (${p.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: SignalBuilder(
        builder: (context) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.appName),
              subtitle: Text(_version),
            ),
            ListTile(
              leading: AppUpdate.showDot ? const Badge(child: Icon(Icons.system_update_alt)) : const Icon(Icons.system_update_alt),
              title: Text(l.checkUpdate),
              onTap: () async {
                toast(context, l.checkingUpdate);
                await AppUpdate.refresh();
                if (!context.mounted) return;
                if (AppUpdate.latest.value == null) {
                  toast(context, l.alreadyLatest);
                  return;
                }
                await AppUpdate.present(context, manual: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_outlined, color: Pro.isPro ? null : Theme.of(context).disabledColor),
              title: Text(l.updateRemind, style: TextStyle(color: Pro.isPro ? null : Theme.of(context).disabledColor)),
              subtitle: Text(l.updateRemindHint),
              trailing: Switch(
                value: Pro.isPro ? Prefs.updateRemind.signal.value : true,
                onChanged: Pro.isPro ? (v) => Prefs.updateRemind.value = v : null,
              ),
              onTap: () {
                if (!Pro.isPro) {
                  toast(context, l.needPro);
                  push(context, const ProPage());
                  return;
                }
                Prefs.updateRemind.value = !Prefs.updateRemind.value;
              },
            ),
            if (AppUpdate.latest.value != null)
              ListTile(
                leading: const Icon(Icons.new_releases_outlined),
                title: Text(l.newVersionFound(AppUpdate.latest.value!)),
                subtitle: Text(
                  AppUpdate.changeLog.value.isEmpty ? l.downloadUpdate : AppUpdate.changeLog.value,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: AppUpdate.openDownload,
              ),
          ],
        ),
      ),
    );
  }
}
