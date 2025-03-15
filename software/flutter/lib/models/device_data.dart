import 'package:flutter/cupertino.dart';

class DeviceData{
  final double oxigen;
  final double alcohol;
  final double temperature;
  final double bpm;

  DeviceData({
    required this.oxigen,
    required this.alcohol,
    required this.temperature,
    required this.bpm
});
  factory DeviceData.fromMap(Map<dynamic, dynamic> map) {
    return DeviceData(
      temperature: (map['temperature'] ?? 0.0).toDouble(), // Handle null
      alcohol: (map['alcohol'] ?? 0.0).toDouble(),
      oxigen: (map['oxygen'] ?? 0.0).toDouble(),
      bpm: (map['bpm']??0.0).toDouble()
    );
  }
}