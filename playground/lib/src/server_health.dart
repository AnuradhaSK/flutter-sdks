// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

enum ServerHealth { unknown, checking, healthy, unhealthy, unreachable }

/// Probes the ThunderID server's readiness endpoint.
///
/// This is the playground's own HTTP call, not an SDK API: thunderid_flutter delegates all
/// networking to the native SDKs and exposes no health check.
class ServerHealthProbe extends ChangeNotifier {
  final String baseUrl;

  ServerHealthProbe(this.baseUrl);

  ServerHealth _status = ServerHealth.unknown;
  String _detail = 'not checked';

  ServerHealth get status => _status;
  String get detail => _detail;

  Future<void> check() async {
    _status = ServerHealth.checking;
    _detail = 'checking';
    notifyListeners();
    final uri = Uri.tryParse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}/health/readiness');
    if (uri == null || uri.host.isEmpty) {
      _set(ServerHealth.unreachable, 'invalid THUNDERID_BASE_URL');
      return;
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    // A local server uses a self-signed certificate. Accept it for the configured host in
    // debug builds only, mirroring allowInsecureConnections in the SDK config.
    if (kDebugMode) {
      client.badCertificateCallback = (cert, host, port) => host == uri.host;
    }
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 6));
      final response = await request.close().timeout(const Duration(seconds: 6));
      await response.drain<void>();
      if (response.statusCode == 200) {
        _set(ServerHealth.healthy, 'healthy');
      } else {
        _set(ServerHealth.unhealthy, 'HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      _set(ServerHealth.unreachable, 'timed out');
    } on SocketException catch (e) {
      _set(ServerHealth.unreachable, e.osError?.message.isNotEmpty == true ? 'unreachable' : e.message);
    } catch (e) {
      _set(ServerHealth.unreachable, e.runtimeType.toString());
    } finally {
      client.close(force: true);
    }
  }

  void _set(ServerHealth status, String detail) {
    _status = status;
    _detail = detail;
    notifyListeners();
  }
}
