import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';

import '../models/device_data.dart';

class DatabsaeService {
  final _dbRef = FirebaseDatabase.instance.ref('devices/67aA37RA6MYUtMN0ZIzKYKWKvAb2/reading');

  Stream<DeviceData> getDeviceDataStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        return DeviceData.fromMap(data);
      }
      return DeviceData(oxigen: 0.0, alcohol: 0.0, temperature: 0.0,bpm: 0.0);
    });
  }
}