import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'network_utils.dart';

part 'friends_model.g.dart';

class Friends extends Iterable<Friend> {
  final LinkedHashMap<String, Friend> _ips2Friends;
  static Friends _state;

  factory Friends({LinkedHashMap<String, Friend> ipMap}) {
    if (_state == null) {
      _state = Friends._internal(ipMap ?? LinkedHashMap());
    }

    return _state;
  }

  Friends._internal(this._ips2Friends);

  void add(Friend f) {
    if (_ips2Friends[f.ip] == null) {
      _ips2Friends[f.ip] = f;
    }
    //maybe TODO check if other is online
    _ips2Friends[f.ip].online = true;
  }

  get length => _ips2Friends.length;

  get asList => _ips2Friends.values.toList();

  Future<SocketOutcome> sendImage(String ip, PickedFile message) async {
    Friend friend = _ips2Friends[ip];
    try {
      Socket imageSocket = await _setupImageSocket(ip);

      imageSocket.add(await message.readAsBytes());

      await imageSocket.flush();
      imageSocket.destroy();
      print("seems to have sent fine");
      friend.online = true;
      return SocketOutcome();
    } on SocketException catch (e) {
      friend.online = false;
      return SocketOutcome(errorMsg: e.toString());
    }
  }

  @override
  Iterator<Friend> get iterator => _ips2Friends.values.iterator;
}

Future<Socket> _setupImageSocket(ip) async {
  Socket negotiationSocket = await Socket.connect(ip, negotiationPort);
  var desiredPort = _randIntBetween(1024, 10000);

  negotiationSocket.write(TransferRequest(
      sender: Friend(negotiationSocket.address.address), port: desiredPort));
  negotiationSocket.destroy();

  return Socket.connect(ip, desiredPort);
}

int _randIntBetween(int low, int high) {
  return (new Random()).nextInt(high - low) + low;
}

@JsonSerializable(nullable: false)
class Friend {
  final String name;
  final String ip;
  bool online;

  Friend(this.ip, {this.name = "unknown", this.online = false});

  String toString() {
    return jsonEncode(this);
  }

  String describe() {
    return "$ip <${online ? "online" : "offline"}>";
  }

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);

  Map<String, dynamic> toJson() => _$FriendToJson(this);
}
