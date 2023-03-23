import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'cross_device.dart';
import 'message.dart';

typedef MessageHandler = Future<Object?> Function(Object? message);

abstract class CrossDeviceConnection {
  CrossDeviceConnection._();

  static Future<CrossDeviceConnection> connect(CrossDevice device) {
    return CrossDeviceConnectionImpl.connect(device);
  }

  int get id;

  bool get isConnected;

  Future<void> get closed;

  Future<Object?> sendMessage(
    String channel,
    Object? message, {
    Duration timeout = const Duration(seconds: 15),
  });

  void setMessageHandler(String channel, MessageHandler? handler);

  void close();
}

class CrossDeviceConnectionImpl implements CrossDeviceConnection {
  CrossDeviceConnectionImpl(this._channel, int? id) {
    if (id != null) {
      _id = id;
    }
    _channel.stream.listen(_onData, onDone: _onDone);
  }

  static Future<CrossDeviceConnection> connect(CrossDevice device) async {
    final channel = IOWebSocketChannel.connect(
      Uri.parse('ws://${device.address.host}:${device.port}'),
      pingInterval: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10),
    );
    await channel.ready;
    final connection = CrossDeviceConnectionImpl(channel, null);
    try {
      await connection._connect();
    } catch (_) {
      connection.close();
      rethrow;
    }
    return connection;
  }

  final WebSocketChannel _channel;

  final _completerMap = HashMap<int, Completer<Object?>>();
  final _handlerMap = HashMap<String, MessageHandler>();

  var _nextId = 0;

  final _closedCompleter = Completer<void>();


  var _id = -1;

  @override
  int get id => 0;

  @override
  Future<void> get closed => _closedCompleter.future;

  bool _isConnected = true;
  @override
  bool get isConnected => _isConnected;

  Future<Object?> _handleInternalMessage(
      String channel, Object? message) async {
    switch (channel) {
      case '_connect':
        return _id;
      default:
        throw UnimplementedError('Channel($channel)');
    }
  }

  void _onDone() {
    _isConnected = false;
    _closedCompleter.complete();
  }

  Future<void> _handleSendMessage(Send message) async {
    try {
      Object? result;
      if (message.internal) {
        result = await _handleInternalMessage(message.channel, message.message);
      } else {
        final handler = _handlerMap[message.channel];
        if (handler == null) {
          _channel.sink.add(MessageCodec.instance.encode(Reply(
            replyId: message.replyId,
            error: 'Could not find handler(${message.channel})',
          )));
          return;
        }
        result = await handler(message.message);
      }
      _channel.sink.add(MessageCodec.instance.encode(Reply(
        replyId: message.replyId,
        result: result,
      )));
    } catch (e) {
      _channel.sink.add(MessageCodec.instance.encode(Reply(
        replyId: message.replyId,
        error: e.toString(),
      )));
    }
  }

  void _handleReplyMessage(Reply message) {
    final completer = _completerMap.remove(message.replyId);
    if (completer == null) {
      return;
    }

    if (message.error != null) {
      StackTrace? stackTrace;
      if (message.stackTrace != null) {
        stackTrace = StackTrace.fromString(message.stackTrace!);
      }
      completer.completeError(message.error!, stackTrace);
    } else {
      completer.complete(message.result);
    }
  }

  void _onData(dynamic data) {
    final bytes = Uint8List.fromList(data as List<int>);
    final message = MessageCodec.instance.decode(bytes);
    if (message is Send) {
      _handleSendMessage(message);
    } else if (message is Reply) {
      _handleReplyMessage(message);
    }
  }

  Future<Object?> _sendMessage(
    String channel,
    Object? message, {
    bool internal = false,
    Duration timeout = const Duration(seconds: 15),
  }) {
    _nextId += 1;
    final replyId = _nextId;
    final completer = Completer<Object?>();
    _completerMap[replyId] = completer;

    _channel.sink.add(MessageCodec.instance.encode(Send(
      replyId: replyId,
      internal: internal,
      channel: channel,
      message: message,
    )));

    final timer = Timer(timeout, () {
      _completerMap.remove(replyId);
      completer.completeError(TimeoutException(null, timeout));
    });

    return completer.future.whenComplete(() {
      timer.cancel();
    });
  }

  Future<void> _connect() async {
    final result = await _sendMessage('_connect', null, internal: true);
    _id = result as int;
  }

  @override
  Future<Object?> sendMessage(
    String channel,
    Object? message, {
    Duration timeout = const Duration(seconds: 15),
  }) {
    return _sendMessage(channel, message, timeout: timeout);
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (handler == null) {
      _handlerMap.remove(channel);
    } else {
      _handlerMap[channel] = handler;
    }
  }

  @override
  void close() {
    _channel.sink.close();
  }
}
