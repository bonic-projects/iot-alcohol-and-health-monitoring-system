// home_viewmodel.dart
import 'package:stacked/stacked.dart';
import 'dart:async';
import '../../../models/device_data.dart';
import 'package:alcohol_and_health_monitoring/services/databsae_service.dart';

class HomeViewModel extends BaseViewModel {
  final _databaseService = DatabsaeService();

  // Reactive values for device data
  ReactiveValue<double> _oxygen = ReactiveValue<double>(0.0);
  ReactiveValue<double> _alcohol = ReactiveValue<double>(0.0);
  ReactiveValue<double> _temperature = ReactiveValue<double>(0.0);
  ReactiveValue<double> _bpm=ReactiveValue<double>(0.0);

  // Stream getter - this was missing in the original implementation
  Stream<DeviceData> getDeviceDataStream() => _databaseService.getDeviceDataStream();

  // Getters for the reactive values
  double get oxygen => _oxygen.value;
  double get alcohol => _alcohol.value;
  double get temperature => _temperature.value;
  double get bpm=>_bpm.value;

  // Stream subscription
  StreamSubscription<DeviceData>? _deviceSubscription;

  void initialize() {
    setBusy(true);
    _setupDeviceDataListener();
    setBusy(false);
  }

  void _setupDeviceDataListener() {
    _deviceSubscription = getDeviceDataStream().listen(
          (deviceData) {
        _oxygen.value = deviceData.oxigen;
        print("$oxygen");
        _alcohol.value = deviceData.alcohol;
        print("$alcohol");
        _temperature.value = deviceData.temperature;
        print("$temperature");
        _bpm.value=deviceData.bpm;
        print("$bpm");
        notifyListeners();
      },
      onError: (error) {
        setError(error);
      },
    );
  }

  // Status getters
  String get oxygenStatus => _getOxygenStatus(_oxygen.value);
  String get alcoholStatus => _getAlcoholStatus(_alcohol.value);
  String get temperatureStatus => _getTemperatureStatus(_temperature.value);
  String get bpmStatus=> _getBpmStatus(_bpm.value);

  String _getOxygenStatus(double value) {
    if (value < 95) return 'Low Oxygen!';
    if (value > 100) return 'Invalid Reading!';
    return 'Normal';
  }

  String _getAlcoholStatus(double value) {
    if (value > 0.08) return 'High Alcohol!';
    return 'Safe';
  }

  String _getTemperatureStatus(double value) {
    if (value > 38) return 'High Temperature!';
    if (value < 35) return 'Low Temperature!';
    return 'Normal';
  }
String _getBpmStatus(double value){
    if(value<30 ) return 'Low Rate!';
    if (value>110) return 'High Rate!';
    return 'Normal';
}
  @override
  void dispose() {
    _deviceSubscription?.cancel();
    super.dispose();
  }
}