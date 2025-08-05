import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputButton extends StatefulWidget {
  final ValueChanged<String> onVoiceInput;

  const VoiceInputButton({
    super.key,
    required this.onVoiceInput,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;
    return (await Permission.microphone.request()).isGranted;
  }

  Future<void> _startRecording() async {
    try {
      if (!await _requestMicrophonePermission()) {
        _showPermissionDialog();
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
        });

        _animationController.repeat(reverse: true);

        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'recording.wav',
          );
        } else {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'recording',
          );
        }
      }
    } catch (e) {
      debugPrint('Recording start error: $e');
      _showErrorDialog('Impossible de démarrer l\'enregistrement');
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      _animationController.stop();
      _animationController.reset();

      final String? path = await _audioRecorder.stop();

      if (path != null) {
        // Simulate speech-to-text processing
        await Future.delayed(const Duration(seconds: 2));

        // Mock transcription result
        final mockTranscriptions = [
          'Appeler le client pour discuter du projet',
          'Préparer la présentation pour demain',
          'Acheter du lait et du pain',
          'Réviser les documents contractuels',
          'Organiser la réunion d\'équipe',
          'Finaliser le rapport mensuel',
        ];

        final randomTranscription = mockTranscriptions[
            DateTime.now().millisecond % mockTranscriptions.length];

        widget.onVoiceInput(randomTranscription);

        setState(() {
          _isProcessing = false;
        });

        _showSuccessDialog();
      } else {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog('Aucun audio enregistré');
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      debugPrint('Recording stop error: $e');
      _showErrorDialog('Erreur lors de l\'arrêt de l\'enregistrement');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Permission requise',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'L\'accès au microphone est nécessaire pour la saisie vocale.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Erreur',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.error,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.tertiary,
            ),
            SizedBox(width: 2.w),
            Text(
              'Succès',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
        content: Text(
          'Votre message vocal a été transcrit avec succès!',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: _isRecording
                    ? AppTheme.lightTheme.colorScheme.error
                    : _isProcessing
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.lightTheme.colorScheme.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: _isRecording ? 12 : 6,
                    spreadRadius: _isRecording ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: _isProcessing
                    ? SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: _isRecording ? 'stop' : 'mic',
                        size: 24,
                        color: Colors.white,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
