import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/prefs.dart';
import '../../l10n/gen/app_localizations.dart';

String hashPin(String pin) => sha256.convert(utf8.encode('hvf-pin:$pin')).toString();

bool get biometricPlatform => Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows;

Future<bool> authenticateBiometric(String reason) async {
  if (!biometricPlatform) return false;
  try {
    final auth = LocalAuthentication();
    if (!await auth.isDeviceSupported()) return false;
    return await auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
  } catch (_) {
    return false;
  }
}

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  bool _error = false;
  bool _authing = false;

  @override
  void initState() {
    super.initState();
    if (Prefs.biometric.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bio());
    }
  }

  Future<void> _bio() async {
    if (_authing || !mounted) return;
    _authing = true;
    final ok = await authenticateBiometric(AppLocalizations.of(context).unlockReason);
    _authing = false;
    if (ok) widget.onUnlocked();
  }

  void _input(String d) {
    if (_pin.length >= 8) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length >= 4 && hashPin(_pin) == Prefs.pinHash.value) {
      widget.onUnlocked();
    } else if (_pin.length == 8) {
      HapticFeedback.heavyImpact();
      setState(() {
        _pin = '';
        _error = true;
      });
    }
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, e) {
                if (e is! KeyDownEvent) return KeyEventResult.ignored;
                final ch = e.character;
                if (ch != null && RegExp(r'^\d$').hasMatch(ch)) {
                  _input(ch);
                  return KeyEventResult.handled;
                }
                if (e.logicalKey == LogicalKeyboardKey.backspace) {
                  _back();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(_error ? l.pinWrong : l.enterPin,
                      style: TextStyle(color: _error ? Theme.of(context).colorScheme.error : null)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pin.length < 4 ? 4 : _pin.length,
                      (i) => Container(
                        margin: const EdgeInsets.all(6),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _pin.length ? Theme.of(context).colorScheme.primary : null,
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PinPad(
                    onDigit: _input,
                    onBackspace: _back,
                    extra: Prefs.biometric.value && biometricPlatform
                        ? IconButton(iconSize: 32, icon: const Icon(Icons.fingerprint), onPressed: _bio)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PinPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Widget? extra;
  const PinPad({super.key, required this.onDigit, required this.onBackspace, this.extra});

  @override
  Widget build(BuildContext context) {
    Widget key(String d) => SizedBox(
          width: 72,
          height: 72,
          child: TextButton(
            style: TextButton.styleFrom(shape: const CircleBorder()),
            onPressed: () => onDigit(d),
            child: Text(d, style: Theme.of(context).textTheme.headlineSmall),
          ),
        );
    Widget row(List<Widget> c) => Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: c);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([key('1'), key('2'), key('3')]),
        row([key('4'), key('5'), key('6')]),
        row([key('7'), key('8'), key('9')]),
        row([
          SizedBox(width: 72, height: 72, child: Center(child: extra)),
          key('0'),
          SizedBox(
            width: 72,
            height: 72,
            child: IconButton(icon: const Icon(Icons.backspace_outlined), onPressed: onBackspace),
          ),
        ]),
      ],
    );
  }
}

/// 设置 PIN：两次输入一致后返回 hash
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String _pin = '';
  String? _first;
  bool _mismatch = false;

  void _input(String d) {
    if (_pin.length >= 8) return;
    setState(() => _pin += d);
  }

  void _confirm() {
    if (_pin.length < 4) return;
    if (_first == null) {
      setState(() {
        _first = _pin;
        _pin = '';
        _mismatch = false;
      });
    } else if (_first == _pin) {
      Navigator.of(context).pop(hashPin(_pin));
    } else {
      setState(() {
        _first = null;
        _pin = '';
        _mismatch = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.setPin)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_mismatch ? l.pinMismatch : (_first == null ? l.pinSetupHint : l.pinConfirm)),
              const SizedBox(height: 16),
              Text('•' * _pin.length, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              PinPad(
                onDigit: _input,
                onBackspace: () {
                  if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
                },
                extra: IconButton(icon: const Icon(Icons.check), onPressed: _pin.length >= 4 ? _confirm : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
