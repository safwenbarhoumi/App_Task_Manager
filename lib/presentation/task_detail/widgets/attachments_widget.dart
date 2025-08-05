import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttachmentsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> attachments;
  final bool isEditMode;
  final Function(Map<String, dynamic>)? onAttachmentAdded;
  final Function(int)? onAttachmentRemoved;

  const AttachmentsWidget({
    super.key,
    required this.attachments,
    this.isEditMode = false,
    this.onAttachmentAdded,
    this.onAttachmentRemoved,
  });

  @override
  State<AttachmentsWidget> createState() => _AttachmentsWidgetState();
}

class _AttachmentsWidgetState extends State<AttachmentsWidget> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (await _requestCameraPermission()) {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
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

          if (!kIsWeb) {
            try {
              await _cameraController!.setFocusMode(FocusMode.auto);
              await _cameraController!.setFlashMode(FlashMode.auto);
            } catch (e) {
              // Ignore unsupported features
            }
          }
        }
      }
    } catch (e) {
      // Handle camera initialization errors silently
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attachments.isEmpty && !widget.isEditMode) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'attach_file',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Pièces jointes',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (widget.isEditMode)
                GestureDetector(
                  onTap: _showAttachmentOptions,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          if (widget.attachments.isNotEmpty)
            _buildAttachmentsList()
          else if (!widget.isEditMode)
            Text(
              'Aucune pièce jointe',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1,
      ),
      itemCount: widget.attachments.length,
      itemBuilder: (context, index) {
        final attachment = widget.attachments[index];
        return _buildAttachmentThumbnail(attachment, index);
      },
    );
  }

  Widget _buildAttachmentThumbnail(Map<String, dynamic> attachment, int index) {
    final String type = attachment['type'] ?? 'file';
    final String name = attachment['name'] ?? 'Fichier';
    final String? url = attachment['url'];

    return GestureDetector(
      onTap: () => _viewAttachment(attachment),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildThumbnailContent(type, url, name),
            ),
            if (widget.isEditMode)
              Positioned(
                top: 1.w,
                right: 1.w,
                child: GestureDetector(
                  onTap: () => widget.onAttachmentRemoved?.call(index),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(String type, String? url, String name) {
    switch (type) {
      case 'image':
        return url != null
            ? CustomImageWidget(
                imageUrl: url,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            : _buildFileIcon('image', name);
      case 'document':
        return _buildFileIcon('description', name);
      case 'pdf':
        return _buildFileIcon('picture_as_pdf', name);
      default:
        return _buildFileIcon('insert_drive_file', name);
    }
  }

  Widget _buildFileIcon(String iconName, String fileName) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(2.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            fileName,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Ajouter une pièce jointe',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),
            _buildAttachmentOption(
              icon: 'camera_alt',
              title: 'Prendre une photo',
              onTap: _capturePhoto,
            ),
            _buildAttachmentOption(
              icon: 'photo_library',
              title: 'Galerie',
              onTap: _pickFromGallery,
            ),
            _buildAttachmentOption(
              icon: 'insert_drive_file',
              title: 'Fichier',
              onTap: _pickFile,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _capturePhoto() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile photo = await _cameraController!.takePicture();
        final attachment = {
          'type': 'image',
          'name': 'Photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          'url': photo.path,
          'size': await photo.length(),
          'createdAt': DateTime.now().toIso8601String(),
        };
        widget.onAttachmentAdded?.call(attachment);
      } else {
        // Fallback to image picker
        final XFile? image =
            await _imagePicker.pickImage(source: ImageSource.camera);
        if (image != null) {
          final attachment = {
            'type': 'image',
            'name': 'Photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
            'url': image.path,
            'size': await image.length(),
            'createdAt': DateTime.now().toIso8601String(),
          };
          widget.onAttachmentAdded?.call(attachment);
        }
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final attachment = {
          'type': 'image',
          'name': image.name,
          'url': image.path,
          'size': await image.length(),
          'createdAt': DateTime.now().toIso8601String(),
        };
        widget.onAttachmentAdded?.call(attachment);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final attachment = {
          'type': _getFileType(file.extension ?? ''),
          'name': file.name,
          'url': file.path,
          'size': file.size,
          'createdAt': DateTime.now().toIso8601String(),
        };
        widget.onAttachmentAdded?.call(attachment);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'document';
      default:
        return 'file';
    }
  }

  void _viewAttachment(Map<String, dynamic> attachment) {
    // Show attachment in full screen or open with system app
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                attachment['name'] ?? 'Fichier',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              if (attachment['type'] == 'image' && attachment['url'] != null)
                CustomImageWidget(
                  imageUrl: attachment['url'],
                  width: 80.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                )
              else
                Container(
                  width: 80.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'insert_drive_file',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        attachment['name'] ?? 'Fichier',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
