import 'package:flutter/material.dart';

import '../../core/errors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/user.dart' as user;
import '../../widgets/common.dart';

class OnlineHistoryPage extends StatefulWidget {
  const OnlineHistoryPage({super.key});

  @override
  State<OnlineHistoryPage> createState() => _OnlineHistoryPageState();
}

class _OnlineHistoryPageState extends State<OnlineHistoryPage> {
  String _sort = 'latest';
  String? _csrf;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.onlineHistory),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'latest', child: Text(l.sortLatest)),
              PopupMenuItem(value: 'popular', child: Text(l.sortPopular)),
              PopupMenuItem(value: 'oldest', child: Text(l.sortOldest)),
            ],
          ),
        ],
      ),
      body: PagedVideoGrid(
        key: ValueKey(_sort),
        loader: (page) => user.onlineHistory(sort: _sort, page: page),
        onFirstPage: (r) => _csrf = r.csrfToken,
        onLongPress: (info, remove) async {
          if (!await confirm(context, l.deleteHistory, content: info.title)) return;
          try {
            await user.deleteOnlineHistory(videoCode: info.videoCode, csrfToken: _csrf);
            remove();
          } catch (e) {
            if (context.mounted) showError(context, e);
          }
        },
      ),
    );
  }
}
