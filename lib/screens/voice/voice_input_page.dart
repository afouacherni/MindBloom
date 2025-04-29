import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import 'package:mindbloom/widgets/back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  String? userId;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _getUserId();
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  Future<void> _initRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Microphone Permission Denied'),
                content: const Text(
                  'Please grant microphone permission to record audio.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
      return;
    }

    try {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to initialize the recorder: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/voice.aac';

      await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

      setState(() {
        _isRecording = true;
        _audioPath = filePath;
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to start recording: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (_audioPath != null && userId != null) {
        await _uploadVocal(userId!, _audioPath!);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to stop recording: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _uploadVocal(String userId, String filePath) async {
    final file = File(filePath);
    final fileName =
        '$userId/vocal-${DateTime.now().millisecondsSinceEpoch}.aac';

    try {
      await Supabase.instance.client.storage
          .from('vocals')
          .upload(
            fileName,
            file,
            fileOptions: FileOptions(cacheControl: '3600'),
          );

      final fileUrl = Supabase.instance.client.storage
          .from('vocals')
          .getPublicUrl(fileName);

      await _addVocalToFirestore(userId, fileUrl);
      _showConfirmationDialog(context);
    } catch (e) {
      _showErrorDialog(context, 'Failed to upload vocal: $e');
    }
  }

  Future<void> _addVocalToFirestore(String userId, String vocalUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'vocals': FieldValue.arrayUnion([vocalUrl]),
      });
    } catch (e) {
      _showErrorDialog(context, 'Failed to update vocal: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Vocal Submitted'),
            content: const Text('Your vocal has been successfully uploaded.'),
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
    if (!_isRecorderInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Record Your Voice'),
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          leading: const BackButtonWidget(), // Correction ici
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Your Voice'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        leading: const BackButtonWidget(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isRecording ? 150 : 120,
                  height: _isRecording ? 150 : 120,
                  decoration: BoxDecoration(
                    color: _isRecording ? AppColors.accent : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            _isRecording ? Colors.redAccent : Colors.blueAccent,
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: FaIcon(
                      _isRecording
                          ? FontAwesomeIcons.pause
                          : FontAwesomeIcons.microphone,
                      size: _isRecording ? 80 : 60,
                      color: Colors.black,
                    ),
                    onPressed: _toggleRecording,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isRecording
                      ? 'Recording... tap to stop'
                      : 'Tap to start recording',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (_audioPath != null)
                  Text(
                    'Audio saved at:\n$_audioPath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }
}
