import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../core/downloads.dart';
import '../core/errors.dart';
import '../core/nav.dart';
import '../core/pro.dart';
import '../l10n/gen/app_localizations.dart';
import '../pages/pro/pro_page.dart';
import '../src/rust/api/models.dart';

/// 未发电时按钮保持可见并置灰，点一下说明并进入发电页。
Future<void> downloadHanimeSelection(BuildContext context, List<HanimeInfo> items) async {
  final l = AppLocalizations.of(context);
  if (!Pro.isPro) {
    toast(context, l.needPro);
    push(context, const ProPage());
    return;
  }
  if (items.isEmpty) return;
  final (added, skipped) = await Downloads.addPendingMany(items);
  if (context.mounted) toast(context, l.downloadQueued(added, skipped));
}

class MultiActionBar extends StatelessWidget {
  final int count;
  final VoidCallback onDownload;
  final VoidCallback? onRemove;
  const MultiActionBar({super.key, required this.count, required this.onDownload, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SignalBuilder(
      builder: (context) {
        final pro = Pro.powered.value;
        final theme = Theme.of(context);
        return Material(
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 8, 4 + bottom),
            child: Row(
              children: [
                Expanded(child: Text(l.selectedCount(count))),
                if (onRemove != null)
                  TextButton(onPressed: count == 0 ? null : onRemove, child: Text(l.delete)),
                TextButton(
                  onPressed: onDownload,
                  child: Text(l.download, style: TextStyle(color: pro ? null : theme.disabledColor)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
