import 'dart:async';
import 'dart:io';

import 'package:my_teacher_wallet/core/error/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppErrors map(Object error) {
    // Timed out waiting for a response — device is online, server/host
    // just never answered in time (often means it's blocked or throttled).
    if (error is TimeoutException) return AppErrors.serverUnreachable();

    if (error is AuthException) return _mapAuthException(error);
    if (error is PostgrestException) return AppErrors.serverUnreachable();
    if (error is SocketException) return _classifySocketException(error);
    if (error is HandshakeException) return AppErrors.serverUnreachable();

    final typeName = error.runtimeType.toString();
    final text = error.toString().toLowerCase();

    // Genuinely offline: OS can't resolve DNS or find any route at all.
    final looksOffline = text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('no address associated with hostname');
    if (looksOffline) return AppErrors.noInternet();

    // Device has a network path, but the specific server refused,
    // reset, or never responded — common when a host is blocked/
    // throttled by an ISP or firewall (needs a VPN to reach it, etc).
    final looksServerUnreachable = typeName.contains('SocketException') ||
        typeName.contains('ClientException') ||
        typeName.contains('AuthRetryableFetchException') ||
        typeName.contains('HandshakeException') ||
        text.contains('connection refused') ||
        text.contains('connection closed') ||
        text.contains('connection reset') ||
        text.contains('timed out') ||
        text.contains('timeout');
    if (looksServerUnreachable) return AppErrors.serverUnreachable();

    return AppErrors.unknown();
  }

  static AppErrors _classifySocketException(SocketException e) {
    final msg = e.message.toLowerCase();
    final osError = e.osError?.message.toLowerCase() ?? '';

    if (msg.contains('failed host lookup') ||
        msg.contains('network is unreachable') ||
        osError.contains('network is unreachable')) {
      return AppErrors.noInternet();
    }
    // Connection refused / reset — device is online, target host isn't.
    return AppErrors.serverUnreachable();
  }

  static AppErrors _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('failed host lookup') || msg.contains('network is unreachable')) {
      return AppErrors.noInternet();
    }
    if (msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('timeout')) {
      return AppErrors.serverUnreachable();
    }
    if (msg.contains('invalid login credentials')) {
      return AppErrors.invalidCredentials('Incorrect email or password.');
    }
    if (msg.contains('email not confirmed')) {
      return AppErrors.invalidCredentials('Please confirm your email before logging in.');
    }
    if (msg.contains('already registered')) {
      return AppErrors.invalidCredentials('An account with this email already exists.');
    }
    if (msg.contains('password') && msg.contains('least')) {
      return AppErrors.invalidCredentials(e.message);
    }

    return e.message.length <= 60
        ? AppErrors.invalidCredentials(e.message)
        : AppErrors.serverUnreachable();
  }
}