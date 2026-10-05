import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Chạm vào màn hình và nói để nhập văn bản...';
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts.setLanguage("vi-VN");
    _tts.speak("Nhận dạng giọng nói. Chạm vào màn hình và bắt đầu nói.");
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            if (_text.isNotEmpty && _text != 'Chạm vào màn hình và nói để nhập văn bản...') {
              _tts.speak("Bạn vừa nói: $_text");
            }
          }
        },
        onError: (val) {
          setState(() => _isListening = false);
          _tts.speak("Lỗi nhận dạng giọng nói.");
        },
      );

      if (available) {
        setState(() => _isListening = true);
        Vibration.vibrate(duration: 50);
        _tts.stop();
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
          localeId: "vi_VN",
        );
      } else {
        _tts.speak("Thiết bị không hỗ trợ nhận dạng giọng nói.");
      }
    } else {
      setState(() => _isListening = false);
      Vibration.vibrate(duration: 100);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isListening ? Colors.green.shade900 : const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Giọng Nói'),
        backgroundColor: Colors.greenAccent.shade700,
      ),
      body: GestureDetector(
        onTap: _listen,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 150,
                color: _isListening ? Colors.white : Colors.greenAccent,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
