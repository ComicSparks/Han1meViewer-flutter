import 'package:flutter/material.dart';

import '../../core/errors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/user.dart' as user;
import '../../widgets/common.dart';

/// 喜欢的影片（likes）/ 稍后观看（saves）
class MyListPage extends StatefulWidget {
  final String listType;
  final String title;
  const MyListPage({super.key, required this.listType, required this.title});

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  String? _csrf;
  String? _desc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PagedVideoGrid(
        loader: (page) => user.myListItems(listType: widget.listType, page: page),
        onFirstPage: (r) {
          _csrf = r.csrfToken;
          if (r.description != null && r.description != _desc) setState(() => _desc = r.description);
        },
        header: _desc == null || _desc!.isEmpty
            ? null
            : Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(_desc!)),
        onLongPress: (info, remove) async {
          if (!await confirm(context, l.removeFromList, content: info.title)) return;
          try {
            await user.deleteMyListItem(listType: widget.listType, videoCode: info.videoCode, csrfToken: _csrf);
            remove();
          } catch (e) {
            if (context.mounted) showError(context, e);
          }
        },
      ),
    );
  }
}
