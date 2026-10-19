// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ClientModel _$$_ClientModelFromJson(Map<String, dynamic> json) =>
    _$_ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      vatNumber: json['vatNumber'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      customerType: json['customerType'] as String?,
      funds: json['funds'] == null ? 0.0 : _parseDouble(json['funds']),
      dues: json['dues'] == null ? 0.0 : _parseDouble(json['dues']),
      permitCredit: json['permitCredit'] == null
          ? false
          : _parseBool(json['permitCredit']),
      creditLimit:
          json['creditLimit'] == null ? 0.0 : _parseDouble(json['creditLimit']),
      createdAt: _parseDateTime(json['createdAt']),
    );

Map<String, dynamic> _$$_ClientModelToJson(_$_ClientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vatNumber': instance.vatNumber,
      'address': instance.address,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'customerType': instance.customerType,
      'funds': instance.funds,
      'dues': instance.dues,
      'permitCredit': instance.permitCredit,
      'creditLimit': instance.creditLimit,
      'createdAt': instance.createdAt.toIso8601String(),
    };
