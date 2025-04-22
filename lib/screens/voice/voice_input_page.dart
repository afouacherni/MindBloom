import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../constants/colors.dart';
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

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Créer un style de texte pour le bouton de retour texte
    final TextStyle backButtonStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    if (!_isRecorderInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Record Your Voice'),
          backgroundColor: AppColors.primary,
          leading: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('<', style: backButtonStyle),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Your Voice'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading:
            false, // Désactive complètement le bouton retour automatique
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '<',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
}
