import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'post.dart';

//Modeled off of Dr Ferrer's socket text chat example
//https://github.com/gjf2a/text_messenger/blob/master/lib/data.dart

const int ourPort = 4444;

class NetworkLog {
  Friends friends = new Friends();
  bool persist;
  var _message_callback;
  List<Image> _feed = [];

  List<Image> get feed => _feed;

  static Future<NetworkLog> getLog(message_callback, {persist=true}) async {
    NetworkLog log = new NetworkLog(message_callback, persist:persist);
    await log._setupServer();
    await log.getFeed();
    return log;
  }

  NetworkLog(this._message_callback, {this.persist=true});

  String current_socket = "";
  //TODO ensure that images from different recipients don't mix into same buffer
  List<int> buffer = [];

  Future<void> _setupServer() async {
    try {
      ServerSocket server = await ServerSocket.bind(
          InternetAddress.anyIPv4, ourPort);
      server.listen(_listenToSocket, onDone: _finishSocket); // StreamSubscription<Socket>
    } on SocketException catch (e) {
      print(e.toString());
    }
  }

  Future<void> getFeed() async {
    //TODO replace with new code
    /*
    var query = await DatabaseHelper.instance.queryAllRows();
    _feed = query
        .map((json) => Cat.fromJson(json))
        .where((cat) => cat != null)
        .toList();
    */
  }

  Future<void> _updateDatabase() async {
    //TODO replace with new code
    //await DatabaseHelper.instance.insert(cat);
    //await getDropDownCatValue();
  }


  //TODO fix everything about this unholy abomination
  void _listenToSocket(Socket socket) {
    socket.listen((data) async {
      current_socket = socket.remoteAddress.address;
      buffer.addAll(data);
      print("got a chunk!");
      print(data.length);

      await Future.delayed(Duration(seconds: 10));
      //TODO fix this awful race condition
      if (buffer.length > 0) {
        var img = Uint8List.fromList(buffer);
        buffer = [];
        _handleIncomingMessage(socket.remoteAddress.address, img);
      }

    });
  }
  void _finishSocket() {
      _handleIncomingMessage(current_socket, Uint8List.fromList(buffer));
  }

  Future<void> sendAll(PickedFile img) async {
    _feed.add(Image.memory(await img.readAsBytes()));
    for (Friend f in friends) {
      f.send(img);
    }
    //await _updateDatabase(message.cat);
    await _message_callback();
  }

  Future<void> sendTo(String ip, PickedFile img) async {
    _feed.add(Image.memory(await img.readAsBytes()));
    await friends.add(ip);
    await friends.sendTo(ip, img);
  }

  void _handleIncomingMessage(String ip, Uint8List incomingData) async {
    Image received = Image.memory(incomingData);
    print("Received '$received' from '$ip' ${received.height} ${received.toString()}");
    //Message m = Message.fromJson(json.decode(received));
    friends.add(ip);
    friends._ips2Friends[ip].online = true;

    //if (!m.protocol) {
      _feed.add(received);
    //  if (this.persist) await _updateDatabase(m.cat);
    //}
    print("$_feed");
    _message_callback();
  }

}

class Friends extends Iterable<Friend> {
  Map<String, Friend> _ips2Friends = {};

  Future<SocketOutcome> add(String ip) {
    print("adding $ip as friend");
    if (_ips2Friends[ip] == null) {
      print("$ip is a new friend");
      _ips2Friends[ip] = Friend(ip);
      return _ips2Friends[ip].confirmConnection();
    }
    return null;
  }

  Future<SocketOutcome> sendTo(String ip, PickedFile message) async {
    return _ips2Friends[ip].send(message);
  }

  @override
  Iterator<Friend> get iterator => _ips2Friends.values.iterator;
}

//removing names for the moment, just to simplify things. May add them back in, so leaving this as its own class
class Friend {
  String _ipAddr;
  bool online = false;

  Friend(this._ipAddr);

  String toString() {
    return "$ipAddr online<$online>";
  }


  Future<SocketOutcome> confirmConnection() async {
    //TODO
    //return send(Message(cat: null, protocol: true));
  }


  Future<SocketOutcome> send(PickedFile message) async {
    try {
      Socket socket = await Socket.connect(_ipAddr, ourPort);
      var bytes = await message.readAsBytes();
      //var str = String.fromCharCodes(bytes);
      socket.add(bytes);
      await socket.flush();
      socket.close();

      print("seems to have sent fine");
      online = true;
      return SocketOutcome();
    } on SocketException catch (e) {
      online = false;
      return SocketOutcome(errorMsg: e.toString());
    }
  }

  String get ipAddr => _ipAddr;
}

class SocketOutcome {
  String _errorMessage;

  SocketOutcome({String errorMsg = ""}) {
    _errorMessage = errorMsg;
  }

  bool get sent => _errorMessage.length == 0;

  String get errorMessage => _errorMessage;

  String toString() {
    return "successful $sent. error [$errorMessage]";
  }
}