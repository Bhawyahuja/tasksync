import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityController {
  ConnectivityController({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>> listenWhenOnline(
    VoidCallback onOnline,
  ) {
    return _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any(
        (result) => result != ConnectivityResult.none,
      );
      if (isOnline) {
        onOnline();
      }
    });
  }
}
