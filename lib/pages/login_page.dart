import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/session.dart';
import '../l10n/gen/app_localizations.dart';
import '../src/rust/api/app.dart' as rapi;
import '../src/rust/api/user.dart' as user;
import '../webview/web_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _cookie = TextEditingController();
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _cookie.dispose();
    super.dispose();
  }

  Future<void> _run(Future<bool> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ok = await action();
      Session.refresh();
      if (!mounted) return;
      if (ok && Session.loggedIn) {
        toast(context, AppLocalizations.of(context).loginSuccess);
        Navigator.of(context).pop(true);
      } else if (ok) {
        toast(context, AppLocalizations.of(context).errLoginFailed);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _webLogin() async {
    final ok = await WebAuth.webLogin(context);
    if (!ok) return false;
    await user.loginVerify();
    return true;
  }

  Future<bool> _formLogin() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) return false;
    await user.login(email: _email.text.trim(), password: _password.text);
    return true;
  }

  Future<bool> _cookieLogin() async {
    final raw = _cookie.text.trim();
    if (raw.isEmpty) return false;
    final n = await rapi.cookiesImportHeader(raw: raw);
    if (n == BigInt.zero) throw '[invalid] cookie';
    await user.loginVerify();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.login)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l.webLogin, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(l.webLoginHint, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              icon: const Icon(Icons.public),
                              label: Text(l.webLogin),
                              onPressed: WebAuth.available ? () => _run(_webLogin) : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 账号密码登录经常需要人机验证，当前表单处理不了，暂时隐藏。
                    // ignore: dead_code
                    if (false) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(l.formLogin, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: InputDecoration(labelText: l.email, border: const OutlineInputBorder()),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  autofillHints: const [AutofillHints.password],
                                  onSubmitted: (_) => _run(_formLogin),
                                  decoration: InputDecoration(
                                    labelText: l.password,
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.tonal(onPressed: () => _run(_formLogin), child: Text(l.login)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Card(
                      child: ExpansionTile(
                        title: Text(l.cookieLogin),
                        subtitle: Text(l.cookieLoginHint, style: Theme.of(context).textTheme.bodySmall),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          TextField(
                            controller: _cookie,
                            minLines: 3,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'remember_web_xxx=...; hanime1_session=...; XSRF-TOKEN=...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonal(onPressed: () => _run(_cookieLogin), child: Text(l.importCookie)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_busy) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
