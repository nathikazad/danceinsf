import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application/controllers/event_controller.dart';
import 'package:image_picker/image_picker.dart';

class UploadSection extends StatefulWidget {
  final String? fileUrl;
  final Function(String?) onFileChanged;

  const UploadSection({
    super.key,
    this.fileUrl,
    required this.onFileChanged,
  });

  @override
  State<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection> {
  bool _isUploading = false;
  final _eventController = EventController();
  final _imagePicker = ImagePicker();

  Future<void> _showUploadOptions() async {
    if (kIsWeb) {
      await _pickAndUploadFile();
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Choose from Files'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploading = true);

        final file = File(image.path);
        final fileUrl = await _eventController.uploadEventFlyer(file);

        if (fileUrl != null) {
          widget.onFileChanged(fileUrl);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isUploading = true);

        String? fileUrl;
        if (kIsWeb) {
          // Handle web platform
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            fileUrl = await _eventController.uploadEventFlyerWeb(
              bytes,
              result.files.first.name,
            );
          }
        } else {
          // Handle mobile platforms
          final file = File(result.files.first.path!);
          fileUrl = await _eventController.uploadEventFlyer(file);
        }

        if (fileUrl != null) {
          widget.onFileChanged(fileUrl);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload file')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Flyer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _showUploadOptions,
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.shade200, width: 1.2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Uploading...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ] else if (widget.fileUrl != null) ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(height: 8),
                    const Text('File Uploaded', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    // Text(widget.fileUrl!, style: const TextStyle(fontSize: 12)),
                  ] else ...[
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      radius: 24,
                      child: Icon(Icons.upload, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text('Upload File', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Supported files PDF, Jpg, Png', style: TextStyle(fontSize: 12)),
                    const Text('Maximum file size 25 MB', style: TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 