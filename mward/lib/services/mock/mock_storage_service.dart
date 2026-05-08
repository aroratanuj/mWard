import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../config/mock_config.dart';

class MockStorageService {
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: MockConfig.mockImageUploadDelay));
  }

  // Upload image to mock storage
  Future<String> uploadImage(String filePath, {String? folder}) async {
    await _simulateDelay();

    // In mock mode, we just copy the file to app documents directory
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = '${timestamp}_$fileName';
      
      final newPath = path.join(directory.path, folder ?? 'uploads', newFileName);
      
      // Create directory if it doesn't exist
      final uploadDir = Directory(path.dirname(newPath));
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }
      
      // Copy file
      final originalFile = File(filePath);
      final newFile = await originalFile.copy(newPath);
      
      debugPrint('Mock: Image uploaded to: ${newFile.path}');
      
      // Return a mock URL
      return 'https://mock-storage.mward.app/uploads/$newFileName';
    } catch (e) {
      debugPrint('Mock: Error uploading image: $e');
      // Return a placeholder URL on error
      return 'https://via.placeholder.com/400x300/CCCCCC/666666?text=Image';
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<String> filePaths, {String? folder}) async {
    final urls = <String>[];
    for (final filePath in filePaths) {
      final url = await uploadImage(filePath, folder: folder);
      urls.add(url);
    }
    return urls;
  }

  // Delete image from mock storage
  Future<void> deleteImage(String imageUrl) async {
    await _simulateDelay();
    
    try {
      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final fileName = pathSegments.last;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, 'uploads', fileName);
        
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Mock: Image deleted: $filePath');
        }
      }
    } catch (e) {
      debugPrint('Mock: Error deleting image: $e');
    }
  }

  // Get download URL for image
  Future<String> getDownloadUrl(String imageUrl) async {
    // In mock mode, just return the URL as is
    return imageUrl;
  }

  // Get signed URL (for temporary access)
  Future<String> getSignedUrl(String imageUrl, {int expiresInSeconds = 3600}) async {
    // In mock mode, just return the URL
    return imageUrl;
  }

  // List files in a folder
  Future<List<String>> listFiles({String? folder}) async {
    final directory = await getApplicationDocumentsDirectory();
    final uploadDir = Directory(path.join(directory.path, folder ?? 'uploads'));
    
    if (!await uploadDir.exists()) {
      return [];
    }
    
    final files = uploadDir.listSync();
    return files
        .where((file) => file is File)
        .map((file) => 'https://mock-storage.mward.app/uploads/${path.basename(file.path)}')
        .toList();
  }

  // Clear all uploaded files
  Future<void> clearAllFiles({String? folder}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uploadDir = Directory(path.join(directory.path, folder ?? 'uploads'));
      
      if (await uploadDir.exists()) {
        await uploadDir.delete(recursive: true);
        debugPrint('Mock: All files cleared from: ${uploadDir.path}');
      }
    } catch (e) {
      debugPrint('Mock: Error clearing files: $e');
    }
  }

  // Get file size
  Future<int> getFileSize(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final fileName = pathSegments.last;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, 'uploads', fileName);
        
        final file = File(filePath);
        if (await file.exists()) {
          return await file.length();
        }
      }
    } catch (e) {
      debugPrint('Mock: Error getting file size: $e');
    }
    return 0;
  }

  // Check if file exists
  Future<bool> fileExists(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final fileName = pathSegments.last;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, 'uploads', fileName);
        
        final file = File(filePath);
        return await file.exists();
      }
    } catch (e) {
      debugPrint('Mock: Error checking file existence: $e');
    }
    return false;
  }
}
