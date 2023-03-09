import 'dart:io';

import 'package:cross_device/src/connection.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:nsd/nsd.dart' as nsd;

import 'utils.dart';

typedef OnConnection = void Function(CrossDeviceConnection connection);

typedef CrossDeviceAuth = Future<bool> Function(
    String deviceName, Object? data);

class CrossDeviceServer {
  CrossDeviceServer._(
    this.displayName,
    this.serviceType,
    this.onConnection,
  );

  static Future<CrossDeviceServer> start({
    required String displayName,
    required String serviceType,
    required OnConnection onConnection,
  }) async {
    final server = CrossDeviceServer._(displayName, serviceType, onConnection);
    await server._start();
    return server;
  }

  final String displayName;

  final String serviceType;

  nsd.Registration? _registration;

  HttpServer? _server;

  final OnConnection onConnection;

  void _onConnection(WebSocketChannel channel, List<String>? protocols) {
    final connection = CrossDeviceConnectionImpl(channel);
    connection.ping().then<void>((_) {
      onConnection(connection);
    }).onError((error, stackTrace) {
      connection.close();
    });
  }

  Future<void> _start() async {
    if (_server != null) {
      return;
    }

    final handler =
        webSocketHandler(_onConnection, pingInterval: Duration(seconds: 15));
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
    _registration = await nsd.register(nsd.Service(
      name: displayName,
      type: getServiceType(serviceType),
      host: _server!.address.host,
      port: _server!.port,
    ));
  }

  Future<void> stop({bool force = false}) async {
    assert(_server != null);
    final server = _server;
    _server = null;
    await server?.close(force: force);
    if (_registration != null) {
      await nsd.unregister(_registration!);
      _registration = null;
    }
  }
}
