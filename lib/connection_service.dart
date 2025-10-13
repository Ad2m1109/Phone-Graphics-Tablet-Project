import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectionService {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _mouseCharacteristic;

  final Guid _serviceUuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  final Guid _characteristicUuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');

  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _connectionStatusController.add(true);
      await _discoverServices();
    } catch (e) {
      _connectionStatusController.add(false);
    }
  }

  void disconnect() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _mouseCharacteristic = null;
    _connectionStatusController.add(false);
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid == _serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == _characteristicUuid) {
            _mouseCharacteristic = characteristic;
            return;
          }
        }
      }
    }
  }

  void sendData(Map<String, dynamic> data) {
    if (_mouseCharacteristic != null) {
      String jsonData = jsonEncode(data);
      _mouseCharacteristic!.write(utf8.encode(jsonData));
    }
  }

  void dispose() {
    stopScan();
    disconnect();
    _connectionStatusController.close();
  }
}