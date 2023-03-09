import 'package:cross_device/cross_device.dart';

void main() async {
  final server = await CrossDeviceServer.start(
    displayName: 'Cross device',
    serviceType: 'cross',
    onConnection: (connection) {},
  );
  // print('awesome: ${awesome.isAwesome}');
}
