import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../widgets/common.dart';

/// 作者上传列表，对应网页 `/user/{id}/uploaded`
class UserVideosPage extends StatefulWidget {
  final String userId;
  final String name;
  const UserVideosPage({super.key, required this.userId, required this.name});

  @override
  State<UserVideosPage> createState() => _UserVideosPageState();
}

class _UserVideosPageState extends State<UserVideosPage> {
  static const _sorts = <String?>[null, 'latest', 'popular', 'oldest'];
  String? _sort;

  String _label(AppLocalizations l, String? sort) => switch (sort) {
        'latest' => l.userSortLatest,
        'popular' => l.userSortPopular,
        'oldest' => l.userSortOldest,
        _ => l.userSortDefault,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                for (final s in _sorts)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_label(l, s)),
                      selected: _sort == s,
                      onSelected: (_) {
                        if (_sort == s) return;
                        setState(() => _sort = s);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PagedVideoGrid(
              key: ValueKey(_sort ?? ''),
              loader: (page) => hanime.userVideos(userId: widget.userId, page: page, sort: _sort),
            ),
          ),
        ],
      ),
    );
  }
}
