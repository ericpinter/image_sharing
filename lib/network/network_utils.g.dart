// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_utils.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferRequest _$TransferRequestFromJson(Map<String, dynamic> json) {
  return TransferRequest(
    sender: Friend.fromJson(json['sender'] as Map<String, dynamic>),
    port: json['port'] as int,
  );
}

Map<String, dynamic> _$TransferRequestToJson(TransferRequest instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'port': instance.port,
    };
