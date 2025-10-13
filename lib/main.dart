import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_graphics_tablet_project/connection_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConnectionService _connectionService;

  @override
  void initState() {
    super.initState();
    _connectionService = ConnectionService();
  }

  @override
  void dispose() {
    _connectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Graphics Tablet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(connectionService: _connectionService),
        '/settings': (context) =>
            SettingsScreen(connectionService: _connectionService),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ConnectionService connectionService;
  const HomeScreen({super.key, required this.connectionService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDrawingMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mouse Pad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          widget.connectionService.sendData({
            'dx': details.delta.dx,
            'dy': details.delta.dy,
            'mode': _isDrawingMode ? 'draw' : 'move',
          });
        },
        child: Container(
          color: _isDrawingMode ? Colors.grey[300] : Colors.white,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isDrawingMode = !_isDrawingMode;
          });
        },
        child: Icon(_isDrawingMode ? Icons.edit : Icons.mouse),
      ),
    );
  }
}

import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  final ConnectionService connectionService;
  const SettingsScreen({super.key, required this.connectionService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _requestPermissionsAndScan() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] == PermissionStatus.granted &&
        statuses[Permission.location] == PermissionStatus.granted) {
      widget.connectionService.startScan();
    } else {
      // Handle the case when permissions are not granted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: Column(
        children: [
          StreamBuilder<bool>(
            stream: widget.connectionService.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data!) {
                return const LinearProgressIndicator();
              }
              return Container();
            },
          ),
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: widget.connectionService.scanResults,
              initialData: const [],
              builder: (c, snapshot) => ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final result = snapshot.data![index];
                  return ListTile(
                    title: Text(result.device.name.isNotEmpty
                        ? result.device.name
                        : 'Unknown Device'),
                    subtitle: Text(result.device.id.toString()),
                    onTap: () => widget.connectionService.connect(result.device),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _requestPermissionsAndScan,
        child: const Icon(Icons.search),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Setup Instructions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '1. Connect your phone and PC to the same WiFi network.\n'
            '2. Open the PGT server application on your PC.\n'
            '3. The app will automatically detect the server, or you can enter the IP address manually in the settings.\n'
            '4. Once connected, the drawing canvas will be active.',
          ),
          SizedBox(height: 20),
          Text(
            'User Guide',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Use your finger or a stylus to draw on the canvas. The drawing will appear in real-time on your PC. Use the toolbar at the bottom to change tools, colors, and other settings.',
          ),
          SizedBox(height: 20),
          Text(
            'Frequently Asked Questions (FAQ)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Q: I can\'t connect to my PC.\n'
            'A: Make sure both devices are on the same WiFi network and that the server application is running on your PC. Check your firewall settings to ensure the PGT application is not blocked.',
          ),
        ],
      ),
    );
  }
}