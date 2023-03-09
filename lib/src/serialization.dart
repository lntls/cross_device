import 'dart:typed_data';

import 'package:standard_message_codec/standard_message_codec.dart' show ReadBuffer, WriteBuffer;

class CrossDeviceWriteBuffer implements WriteBuffer {
  CrossDeviceWriteBuffer({int startCapacity = 32})
      : _buffer = WriteBuffer(startCapacity: startCapacity);

  final WriteBuffer _buffer;

  @override
  ByteData done() {
    return _buffer.done();
  }

  @override
  void putFloat32List(Float32List list) {
    _buffer.putFloat32List(list);
  }

  @override
  void putFloat64(double value, {Endian? endian}) {
    _buffer.putFloat64(value, endian: endian ?? Endian.little);
  }

  @override
  void putFloat64List(Float64List list) {
    _buffer.putFloat64List(list);
  }

  @override
  void putInt32(int value, {Endian? endian}) {
    _buffer.putInt32(value, endian: endian ?? Endian.little);
  }

  @override
  void putInt32List(Int32List list) {
    _buffer.putInt32List(list);
  }

  @override
  void putInt64(int value, {Endian? endian}) {
    _buffer.putInt64(value, endian: endian ?? Endian.little);
  }

  @override
  void putInt64List(Int64List list) {
    _buffer.putInt64List(list);
  }

  @override
  void putUint16(int value, {Endian? endian}) {
    _buffer.putUint16(value, endian: endian ?? Endian.little);
  }

  @override
  void putUint32(int value, {Endian? endian}) {
    _buffer.putUint32(value, endian: endian ?? Endian.little);
  }

  @override
  void putUint8(int byte) {
    _buffer.putUint8(byte);
  }

  @override
  void putUint8List(Uint8List list) {
    _buffer.putUint8List(list);
  }
}

class CrossDeviceReadBuffer implements ReadBuffer {
  CrossDeviceReadBuffer(ByteData data) : _buffer = ReadBuffer(data);

  final ReadBuffer _buffer;

  @override
  ByteData get data => _buffer.data;

  @override
  Float32List getFloat32List(int length) {
    return _buffer.getFloat32List(length);
  }

  @override
  double getFloat64({Endian? endian}) {
    return _buffer.getFloat64(endian: endian ?? Endian.little);
  }

  @override
  Float64List getFloat64List(int length) {
    return _buffer.getFloat64List(length);
  }

  @override
  int getInt32({Endian? endian}) {
    return _buffer.getInt32(endian: endian ?? Endian.little);
  }

  @override
  Int32List getInt32List(int length) {
    return _buffer.getInt32List(length);
  }

  @override
  int getInt64({Endian? endian}) {
    return _buffer.getInt64(endian: endian ?? Endian.little);
  }

  @override
  Int64List getInt64List(int length) {
    return _buffer.getInt64List(length);
  }

  @override
  int getUint16({Endian? endian}) {
    return _buffer.getUint16(endian: endian ?? Endian.little);
  }

  @override
  int getUint32({Endian? endian}) {
    return _buffer.getUint32(endian: endian ?? Endian.little);
  }

  @override
  int getUint8() {
    return _buffer.getUint8();
  }

  @override
  Uint8List getUint8List(int length) {
    return _buffer.getUint8List(length);
  }

  @override
  bool get hasRemaining => _buffer.hasRemaining;
}
