import 'connection.dart';

typedef MethodHandler<R> = Future<Object?> Function(String method, Object? args);

class CrossDeviceMethodChannel {
  const CrossDeviceMethodChannel(this.name, this.connection);

  final String name;

  final CrossDeviceConnection connection;

  Future<T> invokeMethod<T>(String method, [Object? args]) async {
    final message = List<Object?>.filled(2, null)
      ..[0] = method
      ..[1] = args;
    final result = await connection.sendMessage(name, message);
    return result as T;
  }

  void setMethodHandler(MethodHandler? handler) {
    if (handler != null) {
      connection.setMessageHandler(name, (message) {
        final list = message as List;
        return handler(list[0] as String, list[1] as Object?);
      });
    } else {
      connection.setMessageHandler(name, null);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is CrossDeviceMethodChannel &&
        name == other.name &&
        connection == other.connection;
  }

  @override
  int get hashCode => Object.hash(name.hashCode, connection.hashCode);
}
