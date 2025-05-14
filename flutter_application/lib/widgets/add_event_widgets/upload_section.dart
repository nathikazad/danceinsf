import 'package:flutter/material.dart';

class UploadSection extends StatelessWidget {
  final VoidCallback onUpload;

  const UploadSection({
    super.key,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Flyer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onUpload,
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
              ),
            ),
          ),
        ),
      ],
    );
  }
} 