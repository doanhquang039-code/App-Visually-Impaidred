import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'screens/ocr_screen.dart';
import 'screens/voice_screen.dart';
import 'screens/location_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MatVietApp());
}

class MatVietApp extends StatelessWidget {
  const MatVietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatViet Mobile',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        primaryColor: const Color(0xFFF0B429), // Gold
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    _speak("Chào mừng bạn đến với Mắt Việt Mobile. Chạm vào màn hình để bắt đầu.");
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _onFeatureTap(String featureName, String announcement, VoidCallback action) {
    _vibrate();
    _speak(announcement);
    action();
  }

  void _callEmergency() async {
    const number = '113'; // Default to police for now
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatViet Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildBigButton(
                      icon: Icons.camera_alt,
                      label: "Đọc Ảnh",
                      color: Colors.blueAccent,
                      onTap: () => _onFeatureTap("OCR", "Đang mở máy ảnh để đọc chữ", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScreen()));
                      }),
                    ),
                    const SizedBox(width: 12),
                    _buildBigButton(
                      icon: Icons.mic,
                      label: "Giọng Nói",
                      color: Colors.greenAccent.shade700,
                      onTap: () => _onFeatureTap("Voice", "Đang mở chức năng nhận dạng giọng nói", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceScreen()));
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    _buildBigButton(
                      icon: Icons.location_on,
                      label: "Định Vị",
                      color: Colors.orangeAccent,
                      onTap: () => _onFeatureTap("Location", "Đang lấy vị trí của bạn", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen()));
                      }),
                    ),
                    const SizedBox(width: 12),
                    _buildBigButton(
                      icon: Icons.sos,
                      label: "Khẩn Cấp",
                      color: Colors.redAccent,
                      onTap: () => _onFeatureTap("Emergency", "Đang gọi khẩn cấp một một ba", _callEmergency),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        // Double tap or long press could be added for confirmation
        child: Semantics(
          label: label,
          button: true,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
