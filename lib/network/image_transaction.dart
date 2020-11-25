import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class ImageTransaction {
  static Future<Image> getImage(ip, port) async {
    try {
      RawSocket socket = await _getSocket(InternetAddress.anyIPv4, port);
      List<int> buffer = [];
      await socket
          .takeWhile((event) => event != RawSocketEvent.readClosed)
          .forEach((event) {
        if (event == RawSocketEvent.read) _readToBuffer(buffer, socket);
      });
      _readToBuffer(buffer, socket);
      socket.close();

      print("got image data $buffer");
      return Image.memory(Uint8List.fromList(buffer));
    } on SocketException catch (e) {
      print("problem getting image");
      print(e.toString());
    }
  }
}

Future<RawSocket> _getSocket(ip, port) async {
  var server = await RawServerSocket.bind(ip, port, shared: true);
  var socket = await server.take(1).first;
  server.close();
  return socket;
}

_readToBuffer(List<int> buffer, socket) {
  var bytes = socket.read();
  if (bytes != null) buffer.addAll(bytes);
}
