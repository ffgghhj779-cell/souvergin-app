import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the current network connectivity status.
/// Emits `true` if connected to WiFi/Mobile/Ethernet/VPN, `false` otherwise.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // connectivity_plus now returns a List<ConnectivityResult>
    return results.any((r) => r != ConnectivityResult.none);
  });
});
