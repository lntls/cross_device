import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;

import 'cross_device.dart';
import 'utils.dart';

class CrossDeviceDiscovery extends Listenable {
  CrossDeviceDiscovery._(this._discovery);

  static Future<CrossDeviceDiscovery> start(String type) async {
    final discovery = await nsd.startDiscovery(
      getServiceType(type),
      ipLookupType: nsd.IpLookupType.v4,
    );
    return CrossDeviceDiscovery._(discovery);
  }

  final nsd.Discovery _discovery;

  Iterable<CrossDevice> get devices {
    return _discovery.services.map((service) {
      return CrossDevice(
        displayName: service.name!,
        address: service.addresses!.first,
        port: service.port!,
      );
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _discovery.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _discovery.removeListener(listener);
  }

  Future<void> stop() async {
    await nsd.stopDiscovery(_discovery);
  }
}
