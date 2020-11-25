import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' as Widget;
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'friends_model.dart';

part 'network_utils.g.dart';

const int negotiationPort = 4444;

@JsonSerializable(nullable: false)
class TransferRequest {
  final Friend sender;
  final int port;

  TransferRequest({this.sender, this.port});

  String toString() {
    return jsonEncode(this);
  }

  factory TransferRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRequestToJson(this);
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

Widget.Image PickedFileToWidget(PickedFile img) {
  return Widget.Image.file(File(img.path));
}

String ipValidate(String value) {
  if (value.isEmpty) {
    return 'Please enter an IP address';
  } else {
    List<String> splitList = value.split('.');
    if (splitList.length != 4) return "Invalid IP Address";
    for (String substring in splitList) {
      if (!isNumeric(substring)) return "Invalid IP Address";
      int num = int.parse(substring);
      if (num < 0 || num > 255) return "Invalid IP Address";
    }
  }
  return null;
}

bool isNumeric(String str) {
  return double.tryParse(str) != null;
}
