import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttachmentSection extends StatefulWidget {
  final List<Map<String, dynamic>> attachments;
  final ValueChanged<List<Map<String, dynamic>>> onAttachmentsChanged;

  const AttachmentSection({
    super.key,
    required this.attachments,
    required this.onAttachmentsChanged,
  });

  @override
  State<AttachmentSection> createState() => _AttachmentSectionState();
}

class _AttachmentSectionState extends State<AttachmentSection> {
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _showCameraPreview = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;

      final camera = kIsWeb
          ? _cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first)
          : _cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();

      final attachment = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'image',
        'name': 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        'path': photo.path,
        'bytes': bytes,
        'size': bytes.length,
      };

      final updatedAttachments = [...widget.attachments, attachment];
      widget.onAttachmentsChanged(updatedAttachments);

      setState(() {
        _showCameraPreview = false;
      });
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final attachment = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'image',
          'name': image.name,
          'path': image.path,
          'bytes': bytes,
          'size': bytes.length,
        };

        final updatedAttachments = [...widget.attachments, attachment];
        widget.onAttachmentsChanged(updatedAttachments);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes =
            kIsWeb ? file.bytes! : await File(file.path!).readAsBytes();

        final attachment = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'document',
          'name': file.name,
          'path': file.path,
          'bytes': bytes,
          'size': file.size,
        };

        final updatedAttachments = [...widget.attachments, attachment];
        widget.onAttachmentsChanged(updatedAttachments);
      }
    } catch (e) {
      debugPrint('Document picker error: $e');
    }
  }

  void _removeAttachment(String id) {
    final updatedAttachments =
        widget.attachments.where((a) => a['id'] != id).toList();
    widget.onAttachmentsChanged(updatedAttachments);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pièces jointes',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        if (_showCameraPreview && _isCameraInitialized) ...[
          Container(
            height: 30.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CameraPreview(_cameraController!),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => _showCameraPreview = false),
                icon: CustomIconWidget(
                  iconName: 'close',
                  size: 18,
                  color: Colors.white,
                ),
                label: Text('Annuler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _capturePhoto,
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  size: 18,
                  color: Colors.white,
                ),
                label: Text('Capturer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
        if (!_showCameraPreview) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCameraInitialized
                      ? () => setState(() => _showCameraPreview = true)
                      : null,
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    size: 18,
                    color: _isCameraInitialized
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                  ),
                  label: Text('Caméra'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isCameraInitialized
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                    side: BorderSide(
                      color: _isCameraInitialized
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: CustomIconWidget(
                    iconName: 'photo_library',
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  label: Text('Galerie'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDocument,
                  icon: CustomIconWidget(
                    iconName: 'attach_file',
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  label: Text('Fichier'),
                ),
              ),
            ],
          ),
        ],
        if (widget.attachments.isNotEmpty) ...[
          SizedBox(height: 2.h),
          ...widget.attachments
              .map((attachment) => _buildAttachmentItem(attachment)),
        ],
      ],
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final isImage = attachment['type'] == 'image';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isImage && attachment['bytes'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                attachment['bytes'] as Uint8List,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
          ] else ...[
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'description',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment['name'] ?? 'Fichier sans nom',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatFileSize(attachment['size'] ?? 0),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeAttachment(attachment['id']),
            icon: CustomIconWidget(
              iconName: 'close',
              size: 18,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),
        ],
      ),
    );
  }
}
