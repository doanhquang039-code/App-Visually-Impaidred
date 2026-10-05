import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final FlutterTts _tts = FlutterTts();
  bool _isProcessing = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _tts.setLanguage("vi-VN");
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(backCamera, ResolutionPreset.high, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
      _tts.speak("Máy ảnh đã sẵn sàng. Chạm vào bất kỳ đâu trên màn hình để chụp và đọc.");
    } catch (e) {
      _tts.speak("Lỗi khởi tạo máy ảnh.");
    }
  }

  Future<void> _captureAndRead() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) return;
    
    setState(() => _isProcessing = true);
    Vibration.vibrate(duration: 50);
    await _tts.speak("Đang xử lý ảnh, vui lòng chờ...");

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String text = recognizedText.text.trim();
      if (text.isEmpty) {
        text = "Không tìm thấy chữ nào trong ảnh.";
      }
      
      setState(() => _recognizedText = text);
      Vibration.vibrate(duration: 100);
      await _tts.speak(text);
      
    } catch (e) {
      await _tts.speak("Có lỗi xảy ra khi đọc ảnh.");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Đọc Ảnh'),
        backgroundColor: Colors.blueAccent,
      ),
      body: GestureDetector(
        onTap: _captureAndRead,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 6),
                ),
              ),
            if (_recognizedText.isNotEmpty && !_isProcessing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _recognizedText,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
