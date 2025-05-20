// import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application/controllers/flyer_controller.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:image_picker/image_picker.dart';

class CustomDottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double radius;
  final EdgeInsets padding;

  const CustomDottedBorder({
    super.key,
    required this.child,
    required this.color,
    this.strokeWidth = 1,
    this.radius = 16,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashWidth = 5;
    final dashSpace = 5;
    final pathMetrics = path.computeMetrics().first;
    final distance = pathMetrics.length;
    var drawn = 0.0;

    while (drawn < distance) {
      final remaining = distance - drawn;
      final toDraw = remaining < dashWidth ? remaining : dashWidth.toDouble();
      canvas.drawPath(
        pathMetrics.extractPath(drawn, drawn + toDraw),
        paint,
      );
      drawn += toDraw + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
        final fileUrl = await FlyerController.uploadEventFlyer(file);

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
            fileUrl = await FlyerController.uploadEventFlyerWeb(
              bytes,
              result.files.first.name,
            );
          }
        } else {
          // Handle mobile platforms
          final file = File(result.files.first.path!);
          fileUrl = await FlyerController.uploadEventFlyer(file);
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
        Text('Flyer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _showUploadOptions,
            //         child: DottedBorder(
            // options: RoundedRectDottedBorderOptions(
            //   color: Theme.of(context).colorScheme.onSecondaryContainer,
            //   dashPattern: [5, 5],
            //   radius: Radius.circular(16),
            //   strokeWidth: 1,
            //   padding: EdgeInsets.all(16),
            // ),
          child: CustomDottedBorder(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            radius: 16,
            strokeWidth: 1,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 140,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUploading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('Uploading...',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ] else if (widget.fileUrl != null) ...[
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 28),
                      const SizedBox(height: 8),
                      const Text('File Uploaded',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                    ] else ...[
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        radius: 24,
                        child: SvgIcon(
                          icon: SvgIconData('assets/icons/upload_icon.svg'),
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Upload File',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                      const SizedBox(height: 4),
                      Text('Supported files PDF, Jpg, Png',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                      Text('Maximum file size 25 MB',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
