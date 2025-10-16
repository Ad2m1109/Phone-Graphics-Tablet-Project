import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ConnectionService {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;

  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  bool _isListening = false;

  Future<void> startListening() async {
    if (_isListening) return;

    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 38383);
      _isListening = true;
      print('[ConnectionService] Server started on port 38383');

      _serverSocket?.listen((Socket client) {
        print('[ConnectionService] Client connected');
        _clientSocket = client;
        _connectionStatusController.add(true);

        client.done.then((_) {
          print('[ConnectionService] Client disconnected');
          _clientSocket = null;
          _connectionStatusController.add(false);
        });
      });
    } catch (e) {
      print('[ConnectionService] Error starting server: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _clientSocket?.close();
    await _serverSocket?.close();
    _clientSocket = null;
    _serverSocket = null;
    _isListening = false;
    _connectionStatusController.add(false);
    print('[ConnectionService] Server stopped');
  }

  void sendData(Map<String, dynamic> data) {
    if (_clientSocket != null) {
      String jsonData = jsonEncode(data);
      _clientSocket?.write('$jsonData\n');
    }
  }

  void dispose() {
    stopListening();
    _connectionStatusController.close();
  }
}
