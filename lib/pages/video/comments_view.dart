import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/errors.dart';
import '../../core/search_options.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';

class CommentsView extends StatefulWidget {
  final String videoCode;
  final ValueChanged<int?>? onTotal;
  const CommentsView({super.key, required this.videoCode, this.onTotal});

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> with AutomaticKeepAliveClientMixin {
  VideoComments? _data;
  Object? _error;
  bool _loading = false;
  final _input = TextEditingController();
  bool _sending = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await hanime.comments(kind: 'video', code: widget.videoCode);
      if (mounted) {
        setState(() => _data = d);
        widget.onTotal?.call(d.total);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final d = _data;
    if (text.isEmpty || d == null || _sending) return;
    setState(() => _sending = true);
    try {
      await hanime.postComment(
        csrfToken: d.csrfToken,
        currentUserId: d.currentUserId ?? Session.state.value.userId ?? '',
        kind: 'video',
        targetId: widget.videoCode,
        text: text,
      );
      _input.clear();
      if (mounted) toast(context, AppLocalizations.of(context).commentSent);
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context);
    final d = _data;
    Widget body;
    if (d == null) {
      body = _error != null ? ErrorView(error: _error!, onRetry: _load) : const Center(child: CircularProgressIndicator());
    } else if (d.comments.isEmpty) {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(children: [SizedBox(height: 200, child: EmptyView(text: l.noComments))]),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: d.comments.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
          itemBuilder: (context, i) => CommentTile(
            comment: d.comments[i],
            csrfToken: d.csrfToken,
            currentUserId: d.currentUserId,
            place: 'comment',
          ),
        ),
      );
    }
    return Column(
      children: [
        if (_loading && d != null) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: body),
        if (Session.loggedIn && d != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l.commentHint,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CommentTile extends StatefulWidget {
  final VideoComment comment;
  final String? csrfToken;
  final String? currentUserId;
  final String place;
  const CommentTile({super.key, required this.comment, this.csrfToken, this.currentUserId, required this.place});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  late int _thumb = widget.comment.thumbUp ?? 0;
  late bool _liked = widget.comment.post.likeStatus;
  late bool _unliked = widget.comment.post.unlikeStatus;

  Future<void> _like(bool positive) async {
    if (!Session.loggedIn) {
      toast(context, AppLocalizations.of(context).errNotLoggedIn);
      return;
    }
    try {
      await hanime.likeComment(
        csrfToken: widget.csrfToken,
        place: widget.place,
        isPositive: positive,
        comment: widget.comment,
      );
      setState(() {
        if (positive) {
          _thumb += _liked ? -1 : (_unliked ? 2 : 1);
          _liked = !_liked;
          _unliked = false;
        } else {
          _thumb += _unliked ? 1 : (_liked ? -2 : -1);
          _unliked = !_unliked;
          _liked = false;
        }
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _reply() async {
    final l = AppLocalizations.of(context);
    final id = widget.comment.id;
    if (id == null) return;
    final text = await inputText(context, l.reply, hint: '@${widget.comment.username}', maxLines: 4);
    if (text == null || text.trim().isEmpty) return;
    try {
      await hanime.postCommentReply(csrfToken: widget.csrfToken, replyCommentId: id, text: text.trim());
      if (mounted) toast(context, l.commentSent);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _report() async {
    final l = AppLocalizations.of(context);
    final reasons = await SearchOptions.reportReasons();
    if (!mounted) return;
    final locale = Localizations.localeOf(context);
    final reason = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l.report),
        children: [
          for (final r in reasons)
            SimpleDialogOption(onPressed: () => Navigator.pop(c, r.key), child: Text(r.label(locale))),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await hanime.reportComment(
        csrfToken: widget.csrfToken,
        currentUserId: widget.currentUserId ?? Session.state.value.userId ?? '',
        reason: reason,
        reportableId: widget.comment.reportableId,
        reportableType: widget.comment.reportableType,
      );
      if (mounted) toast(context, l.reportSent);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _showReplies() {
    final id = widget.comment.id;
    if (id == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scroll) => _Replies(commentId: id, parent: widget, scroll: scroll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = widget.comment;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(child: NetImage(c.avatar, width: 40, height: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.username, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                    ),
                    Text(c.date, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: c.content));
                    toast(context, l.copied);
                  },
                  child: Text(c.content),
                ),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      icon: Icon(_liked ? Icons.thumb_up : Icons.thumb_up_outlined),
                      onPressed: () => _like(true),
                    ),
                    Text('$_thumb', style: theme.textTheme.bodySmall),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      icon: Icon(_unliked ? Icons.thumb_down : Icons.thumb_down_outlined),
                      onPressed: () => _like(false),
                    ),
                    if (!c.isChild && Session.loggedIn)
                      TextButton(onPressed: _reply, child: Text(l.reply)),
                    if (c.hasMoreReplies && !c.isChild)
                      TextButton(
                        onPressed: _showReplies,
                        child: Text(l.viewReplies(c.replyCount ?? 0)),
                      ),
                    const Spacer(),
                    if (Session.loggedIn && c.reportableId != null)
                      PopupMenuButton<int>(
                        iconSize: 18,
                        onSelected: (_) => _report(),
                        itemBuilder: (_) => [PopupMenuItem(value: 0, child: Text(l.report))],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Replies extends StatefulWidget {
  final String commentId;
  final CommentTile parent;
  final ScrollController scroll;
  const _Replies({required this.commentId, required this.parent, required this.scroll});

  @override
  State<_Replies> createState() => _RepliesState();
}

class _RepliesState extends State<_Replies> {
  VideoComments? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final d = await hanime.commentReplies(commentId: widget.commentId);
      if (mounted) setState(() => _data = d);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    if (d == null) {
      return _error != null ? ErrorView(error: _error!, onRetry: _load) : const Center(child: CircularProgressIndicator());
    }
    return ListView(
      controller: widget.scroll,
      children: [
        CommentTile(
          comment: widget.parent.comment,
          csrfToken: widget.parent.csrfToken,
          currentUserId: widget.parent.currentUserId,
          place: 'comment',
        ),
        const Divider(),
        for (final r in d.comments)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: CommentTile(
              comment: r,
              csrfToken: d.csrfToken ?? widget.parent.csrfToken,
              currentUserId: d.currentUserId ?? widget.parent.currentUserId,
              place: 'reply',
            ),
          ),
      ],
    );
  }
}
