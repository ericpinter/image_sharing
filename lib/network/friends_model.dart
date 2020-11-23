import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'network_utils.dart';

part 'friends_model.g.dart';

class Friends extends Iterable<Friend> {
  Map<String, Friend> _ips2Friends = {};
  static Friends _state;

  factory Friends({Map<String, Friend> ipMap}) {
    if (_state == null) {
      _state = Friends._internal(ipMap ?? {});
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

  Future<SocketOutcome> sendImage(String ip, PickedFile message) async {
    Friend friend = _ips2Friends[ip];
    try {
      Socket negotiationSocket = await Socket.connect(ip, negotiationPort);
      var r = new Random();

      //we will request a random port between 1024 and 10000. I want to put this code somewhere else but it isn't worth abstracting for it
      var desiredPort = r.nextInt(10000 - 1024) + 1024;
      print("sending open request");
      print("sending to $ip on $desiredPort");
      negotiationSocket.write(TransferRequest(
          sender: Friend(negotiationSocket.address.address),
          port: desiredPort));

      Socket imageSocket = await Socket.connect(ip, desiredPort);
      print("sending image stuff");

      var bytes = await message.readAsBytes();
      imageSocket.add(bytes);

      await imageSocket.flush();
      imageSocket.destroy();
      negotiationSocket.destroy();
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

class FriendsSelection {
  Friends _friends;
  List<bool> _isSelected;
  var reload;

  get friends => _friends;

  Set<Friend> selected() {
    List<Friend> _friendsList = _friends._ips2Friends.values.toList();
    return {
      for (int i = 0; i < _friendsList.length; i++)
        if (_isSelected[i]) _friendsList[i]
    };
  }

  FriendsSelection(this._friends, this.reload) {
    _isSelected = [for (int i = 0; i < _friends.length; i++) false];
  }

  add(Friend f) {
    var old_length = friends.length;
    _friends.add(f);
    if (friends.length > old_length) _isSelected.add(false);
    reload();
  }

  List<Widget> asWidgetList() {
    List<Friend> _friendsList = _friends._ips2Friends.values.toList();
    print(_friendsList);
    print(_isSelected);

    return [
      for (int i = 0; i < _friends.length; i++)
        CheckboxListTile(
            title: Text(_friendsList[i].name),
            subtitle: Text(_friendsList[i].describe()),
            secondary: Icon(Icons.person),
            value: _isSelected[i],
            onChanged: (bool newValue) {
              _isSelected[i] = newValue;
              reload();
            })
    ];
  }
}
