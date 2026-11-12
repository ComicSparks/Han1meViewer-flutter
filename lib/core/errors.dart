import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

import '../l10n/gen/app_localizations.dart';
import 'pro.dart';

/// Rust 侧错误统一为 `[code] message`
class AppError {
  final String code;
  final String message;
  const AppError(this.code, this.message);

  static final _re = RegExp(r'^\[([a-z0-9_]+)\]\s*(.*)$', dotAll: true);

  factory AppError.from(Object e) {
    final raw = e is AnyhowException ? e.message : e.toString();
    final first = raw.trim();
    final m = _re.firstMatch(first);
    if (m != null) return AppError(m.group(1)!, m.group(2)!.split('\n').first);
    return AppError('unknown', first.split('\n').first);
  }

  bool get isNetwork => const {'timeout', 'dns', 'tls', 'proxy', 'connect', 'network'}.contains(code);
  bool get needLogin => code == 'not_logged_in' || code == 'login_expired';

  String describe(AppLocalizations l) {
    final head = switch (code) {
      'timeout' => l.errTimeout,
      'dns' => l.errDns,
      'tls' => l.errTls,
      'proxy' => l.errProxy,
      'connect' || 'network' => l.errNetwork,
      'cf_challenge' => l.errCfChallenge,
      'cf_mismatch' => l.errCfMismatch,
      'ip_blocked' => l.errIpBlocked,
      'not_found' => l.errNotFound,
      'not_logged_in' => l.errNotLoggedIn,
      'login_expired' => l.errLoginExpired,
      'login_failed' => l.errLoginFailed,
      'parse' => l.errParse,
      'form' => message,
      'exists' => l.errExists,
      'invalid' => l.errInvalid,
      'invalid_image' => l.errInvalidImage,
      'need_pro' => l.proPageLimit(freeMaxPage),
      'pro' => _proMessage(l, message),
      _ when code.startsWith('http_') => l.errHttp(code.substring(5)),
      _ => null,
    };
    if (head == null) return message;
    if (head == message || message.isEmpty || code == 'form' || code == 'pro' || code == 'need_pro') {
      return head;
    }
    return '$head\n$message';
  }
}

String _proMessage(AppLocalizations l, String code) {
  return switch (code) {
    'NETWORK_TIMEOUT' => l.proErrNetworkTimeout,
    'NETWORK_UNREACHABLE' => l.proErrNetworkUnreachable,
    'SERVER_FAILED' => l.proErrServerFailed,
    'SERVER_RESPONSE_INVALID' => l.proErrServerInvalid,
    'REQUEST_INVALID' => l.proErrRequestInvalid,
    'ORDER_NOT_SYNCED' => l.proErrOrderNotSynced,
    'ORDER_ALREADY_USED' => l.proErrOrderUsed,
    'ORDER_AMOUNT_INVALID' => l.proErrOrderAmount,
    'TICKET_NOT_FOUND' => l.proErrTicketNotFound,
    'TICKET_ALREADY_USED' => l.proErrTicketUsed,
    'TICKET_EVENT_USED' => l.proErrTicketEventUsed,
    'DEVICE_TIME' => l.proErrDeviceTime,
    'PAT_NOT_BOUND' => l.proErrPatNotBound,
    _ => code,
  };
}

String errorText(BuildContext context, Object e) =>
    AppError.from(e).describe(AppLocalizations.of(context));

void showError(BuildContext context, Object e) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText(context, e))));
}

void toast(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
}
