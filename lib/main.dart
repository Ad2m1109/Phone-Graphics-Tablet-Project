import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Offset?> points = <Offset?>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
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
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(points),
          child: Container(),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => oldDelegate.points != points;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBluetoothEnabled = true;
  bool _isWifiEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Connect to PC'),
            subtitle: const Text('IP Address: 192.168.1.100'), // Placeholder
            leading: const Icon(Icons.computer),
            onTap: () {
              // TODO: Implement PC connection logic
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Bluetooth'),
            subtitle: const Text('Enable or disable Bluetooth'),
            value: _isBluetoothEnabled,
            onChanged: (bool value) {
              setState(() {
                _isBluetoothEnabled = value;
              });
            },
            secondary: const Icon(Icons.bluetooth),
          ),
          SwitchListTile(
            title: const Text('WiFi'),
            subtitle: const Text('Enable or disable WiFi'),
            value: _isWifiEnabled,
            onChanged: (bool value) {
              setState(() {
                _isWifiEnabled = value;
              });
            },
            secondary: const Icon(Icons.wifi),
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