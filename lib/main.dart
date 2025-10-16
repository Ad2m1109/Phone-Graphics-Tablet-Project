import 'package:flutter/material.dart';
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
  DateTime? _twoFingerTapStartTime;

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
        onDoubleTap: () {
          widget.connectionService.sendData({
            'dx': 0,
            'dy': 0,
            'mode': 'double_click',
          });
        },
        onScaleStart: (details) {
          _twoFingerTapStartTime = DateTime.now();
        },
        onScaleEnd: (details) {
          if (_twoFingerTapStartTime != null &&
              DateTime.now().difference(_twoFingerTapStartTime!) <
                  const Duration(milliseconds: 200)) {
            widget.connectionService.sendData({
              'dx': 0,
              'dy
              ': 0,
              'mode': 'right_click',
            });
          }
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

class SettingsScreen extends StatefulWidget {
  final ConnectionService connectionService;
  const SettingsScreen({super.key, required this.connectionService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    widget.connectionService.connectionStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          // Update UI based on connection status if needed
        });
      }
    });
  }

  Future<void> _toggleListening(bool value) async {
    if (value) {
      await widget.connectionService.startListening();
      setState(() {
        _isListening = true;
      });
    } else {
      await widget.connectionService.stopListening();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Start USB Server'),
            subtitle: Text(_isListening ? 'Listening for connection' : 'Server stopped'),
            value: _isListening,
            onChanged: _toggleListening,
            secondary: const Icon(Icons.usb),
          ),
          StreamBuilder<bool>(
            stream: widget.connectionService.connectionStatusStream,
            initialData: false,
            builder: (c, snapshot) {
              final isConnected = snapshot.data ?? false;
              return ListTile(
                title: const Text('Connection Status'),
                subtitle: Text(isConnected ? 'Connected' : 'Disconnected'),
                leading: Icon(
                  isConnected ? Icons.power : Icons.power_off,
                  color: isConnected ? Colors.green : Colors.grey,
                ),
              );
            },
          ),
        ],
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
            'USB Mode Setup Instructions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '1. Enable Developer Options and USB Debugging on your Android phone.\n'
            '2. Install Android Debug Bridge (adb) on your PC.\n'
            '3. Connect your phone to your PC with a USB cable.\n'
            '4. Open a terminal on your PC and run the command: adb forward tcp:38383 tcp:38383\n'
            '5. Run the PC client application.\n'
            '6. In this app, go to Settings and enable \'Start USB Server\'.\n'
            '7. The PC client should now show a \'Phone connected\' message.',
          ),
          SizedBox(height: 20),
          Text(
            'User Guide',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Use your finger to move the mouse cursor. Use the button on the screen to toggle between move and draw modes.',
          ),
        ],
      ),
    );
  }
}