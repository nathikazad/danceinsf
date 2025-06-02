import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class FlyerController {
  static final supabase = Supabase.instance.client;

  static Future<String?> uploadEventFlyer(File file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Generate a unique file name
      final fileExt = path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'flyers/$fileName';

      // Upload file to Supabase Storage
      final response = await supabase.storage
          .from('flyers')
          .upload(filePath, file);

      if (response.isEmpty) {
        throw Exception('Failed to upload file');
      }

      // Get the public URL
      final fileUrl = supabase.storage.from('flyers').getPublicUrl(filePath);
      print('File URL: $fileUrl');

      return fileUrl;
    } catch (error, stackTrace) {
      print('Error uploading file: $error');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<String?> uploadEventFlyerWeb(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Generate a unique file name
      final fileExt = path.extension(fileName);
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = 'flyers/$uniqueFileName';

      // Convert List<int> to Uint8List
      final uint8List = Uint8List.fromList(bytes);

      // Upload file to Supabase Storage
      final response = await supabase.storage
          .from('flyers')
          .uploadBinary(filePath, uint8List);

      if (response.isEmpty) {
        throw Exception('Failed to upload file');
      }

      // Get the public URL
      final fileUrl = supabase.storage.from('flyers').getPublicUrl(filePath);

      return fileUrl;
    } catch (error, stackTrace) {
      print('Error uploading file: $error');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
