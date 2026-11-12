import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';

import '../../core/errors.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/models.dart';
import '../../src/rust/api/user.dart' as user;
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserAccount? _acc;
  Object? _error;
  bool _busy = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  int _avatarVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _old, _new, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final a = await user.accountPage();
      if (!mounted) return;
      setState(() {
        _acc = a;
        _name.text = a.username;
        _email.text = a.email;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _run(Future<void> Function() f, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await f();
      if (mounted) toast(context, success);
      await _load();
      await user.loginVerify().catchError((_) => Session.state.value);
      Session.refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAvatar() async {
    String? path;
    if (Platform.isAndroid || Platform.isIOS) {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery);
      path = x?.path;
    } else {
      final f = await openFile(acceptedTypeGroups: [
        const XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png', 'webp']),
      ]);
      path = f?.path;
    }
    if (path == null || !mounted) return;
    final l = AppLocalizations.of(context);
    await _run(() => user.updateAvatar(csrfToken: _acc?.csrfToken, imagePath: path!), l.saved);
    setState(() => _avatarVersion++);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = _acc;
    return Scaffold(
      appBar: AppBar(title: Text(l.account)),
      body: a == null
          ? (_error != null ? ErrorView(error: _error!, onRetry: _load) : const Center(child: CircularProgressIndicator()))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
                  children: [
                    if (_busy) const LinearProgressIndicator(),
                    Center(
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _pickAvatar,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: NetImage(
                                '${a.avatarUrl}${a.avatarUrl.contains('?') ? '&' : '?'}v=$_avatarVersion',
                                width: 96,
                                height: 96,
                              ),
                            ),
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(radius: 14, child: Icon(Icons.edit, size: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: Text(a.joinedLabel ?? '', style: Theme.of(context).textTheme.bodySmall)),
                    Center(
                      child: Text(l.accountStats(a.subscriberCount, a.videoCount),
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const SizedBox(height: 16),
                    Text(l.profile, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(controller: _name, decoration: InputDecoration(labelText: l.username, border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      readOnly: true,
                      decoration: InputDecoration(labelText: l.email, border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => _run(
                          () => user.updateProfile(csrfToken: a.csrfToken, name: _name.text.trim(), email: _email.text.trim()),
                          l.saved,
                        ),
                        child: Text(l.save),
                      ),
                    ),
                    const Divider(height: 32),
                    Text(l.changePassword, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(controller: _old, obscureText: true, decoration: InputDecoration(labelText: l.oldPassword, border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _new, obscureText: true, decoration: InputDecoration(labelText: l.newPassword, border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(labelText: l.confirmPassword, border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () {
                          if (_new.text != _confirm.text) {
                            toast(context, l.pinMismatch);
                            return;
                          }
                          _run(
                            () => user.updatePassword(
                              csrfToken: a.csrfToken,
                              oldPassword: _old.text,
                              newPassword: _new.text,
                              confirm: _confirm.text,
                            ),
                            l.saved,
                          );
                        },
                        child: Text(l.changePassword),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
