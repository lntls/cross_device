import 'dart:typed_data';

import 'package:standard_message_codec/standard_message_codec.dart';

import 'serialization.dart';

abstract class Message {}

class Send implements Message {
  Send({
    required this.replyId,
    required this.internal,
    required this.channel,
    required this.message,
  });

  final int replyId;
  final bool internal;
  final String channel;
  final Object? message;
}

class Reply implements Message {
  Reply({
    required this.replyId,
    this.result,
    this.error,
    this.stackTrace,
  });

  final int replyId;
  final Object? result;
  final Object? error;
  final String? stackTrace;
}

class MessageCodec {
  const MessageCodec._();

  static const instance = MessageCodec._();

  static const _kSendMessage = 0;
  static const _kReplyMessage = 1;

  static const _codec = StandardMessageCodec();

  Uint8List encode(Message message) {
    final buffer = CrossDeviceWriteBuffer(startCapacity: 64);
    if (message is Send) {
      buffer.putUint8(_kSendMessage);
      buffer.putInt64(message.replyId);
      _codec.writeValue(buffer, message.internal);
      _codec.writeValue(buffer, message.channel);
      _codec.writeValue(buffer, message.message);
    } else if (message is Reply) {
      buffer.putUint8(_kReplyMessage);
      buffer.putInt64(message.replyId);
      _codec.writeValue(buffer, message.result);
      _codec.writeValue(buffer, message.error);
      _codec.writeValue(buffer, message.stackTrace);
    } else {
      throw UnimplementedError();
    }
    
    final data = buffer.done();
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Message decode(Uint8List bytes) {
    final buffer = CrossDeviceReadBuffer(
        bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes));
    final type = buffer.getUint8();
    switch (type) {
      case _kSendMessage:
        final replyId = buffer.getInt64();
        final internal = _codec.readValue(buffer) as bool;
        final channel = _codec.readValue(buffer) as String;
        final message = _codec.readValue(buffer);
        return Send(
          replyId: replyId,
          internal: internal,
          channel: channel,
          message: message,
        );
      case _kReplyMessage:
        final replyId = buffer.getInt64();
        final result = _codec.readValue(buffer);
        final error = _codec.readValue(buffer);
        final stackTrace = _codec.readValue(buffer) as String?;
        return Reply(
          replyId: replyId,
          result: result,
          error: error,
          stackTrace: stackTrace,
        );
      default:
        throw UnimplementedError('Message type $type');
    }
  }
}
