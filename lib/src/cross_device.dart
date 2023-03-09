import 'dart:io';

class CrossDevice {
  CrossDevice({
    required this.displayName,
    required this.address,
    required this.port,
  });

  final String displayName;
  final InternetAddress address;
  final int port;

  @override
  int get hashCode => Object.hash(displayName, address, port);

  @override
  bool operator ==(Object other) {
    return other is CrossDevice &&
        other.displayName == displayName &&
        other.address == address &&
        other.port == port;
  }
}
