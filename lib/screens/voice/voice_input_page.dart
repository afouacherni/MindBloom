import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants/colors.dart';
import 'package:mindbloom/widgets/back_button.dart';

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _audioPath;
  bool _loading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      _showErrorDialog('Microphone permission is required to record audio');
      return;
    }

    try {
      await _recorder.openRecorder();
      setState(() => _isRecorderInitialized = true);
    } catch (e) {
      _showErrorDialog('Failed to initialize recorder: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
      setState(() {
        _isRecording = true;
        _audioPath = filePath;
      });
    } catch (e) {
      _showErrorDialog('Recording failed: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() => _isRecording = false);

      if (_audioPath != null) {
        await _uploadVocal(_audioPath!);
      }
    } catch (e) {
      _showErrorDialog('Failed to stop recording: $e');
    }
  }

  Future<void> _uploadVocal(String filePath) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showErrorDialog('User not authenticated');
      return;
    }

    setState(() => _loading = true);

    try {
      final session = _supabase.auth.currentSession;
      final accessToken = session?.accessToken;

      if (accessToken == null) {
        _showErrorDialog('No access token available');
        return;
      }

      final file = File(filePath);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.67.202:5000/predict_audio'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['user_id'] = user.id;
      request.headers['Authorization'] = 'Bearer $accessToken';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = json.decode(responseData);

        final double score = responseJson['score'];
        final String fileUrl = responseJson['url'];

        await _supabase.from('vocal_recordings').insert({
          'user_id': user.id,
          'file_path':
              'vocals/${user.id}/${DateTime.now().millisecondsSinceEpoch}.aac',
          'url': fileUrl,
          'score': score,
          'created_at': DateTime.now().toIso8601String(),
        });

        _showSuccessDialog(score);
      } else {
        _showErrorDialog('API failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(double score) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: Text('Recording saved with depression score: $score'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recording'),
        backgroundColor: AppColors.primary,
        leading: const BackButtonWidget(),
      ),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isRecording ? 'Recording...' : 'Tap to record',
                      style: const TextStyle(fontSize: 20),
                    ),
                    if (_audioPath != null) ...[
                      const SizedBox(height: 20),
                      const Text('Last recording:'),
                      Text(_audioPath!, textAlign: TextAlign.center),
                    ],
                  ],
                ),
      ),
    );
  }
}
