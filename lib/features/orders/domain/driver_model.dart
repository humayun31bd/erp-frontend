import 'package:flutter/material.dart';

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleType; // 'bike', 'car', 'van'
  final String? vehiclePlate;
  final bool isActive;
  final bool isAvailable;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleType = 'bike',
    this.vehiclePlate,
    this.isActive = true,
    this.isAvailable = true,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Driver',
      phone: json['phone']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? 'bike',
      vehiclePlate: json['vehiclePlate']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == 1,
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 1,
    );
  }

  IconData get vehicleIcon {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'van':
        return Icons.local_shipping_rounded;
      case 'bike':
      default:
        return Icons.two_wheeler_rounded;
    }
  }

  String get vehicleLabel {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return 'Car (سيارة)';
      case 'van':
        return 'Van (فان)';
      case 'bike':
      default:
        return 'Motorcycle (دراجة)';
    }
  }
}
