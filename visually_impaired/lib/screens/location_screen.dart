import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final FlutterTts _tts = FlutterTts();
  String _locationMessage = "Chạm vào màn hình để lấy vị trí và thời tiết hiện tại";
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("vi-VN");
    _tts.speak("Định vị và Thời tiết. Chạm để lấy tọa độ.");
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _tts.speak("Dịch vụ định vị đang bị tắt. Vui lòng bật lên.");
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _tts.speak("Bạn đã từ chối quyền định vị.");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _tts.speak("Quyền định vị bị từ chối vĩnh viễn.");
      return false;
    }
    return true;
  }

  Future<void> _getLocation() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    Vibration.vibrate(duration: 50);
    await _tts.speak("Đang tìm vị trí, vui lòng chờ...");

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      
      String msg = "Tọa độ của bạn là. Vĩ độ: ${position.latitude.toStringAsFixed(4)}. Kinh độ: ${position.longitude.toStringAsFixed(4)}. Vuốt lên để mở bản đồ.";
      setState(() {
        _locationMessage = msg;
        _isLoading = false;
      });
      Vibration.vibrate(duration: 100);
      await _tts.speak(msg);
      
    } catch (e) {
      setState(() => _isLoading = false);
      _tts.speak("Lỗi khi lấy vị trí.");
    }
  }

  Future<void> _openMaps() async {
    if (_currentPosition == null) {
      _tts.speak("Chưa có vị trí. Vui lòng chạm vào màn hình để lấy vị trí trước.");
      return;
    }
    _tts.speak("Đang mở bản đồ google");
    final url = 'https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _tts.speak("Không thể mở bản đồ.");
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Định Vị & Bản Đồ'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: GestureDetector(
        onTap: _getLocation,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swipe Up
            _openMaps();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 150,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.orangeAccent)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _locationMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
