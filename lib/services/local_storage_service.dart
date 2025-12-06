// Local Storage Service
//
// Handles file storage operations locally instead of Firebase Storage
// Files are saved to app's local directory and paths stored in database

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._init();

  LocalStorageService._init();

  /// Get the app's local storage directory
  Future<Directory> _getStorageDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory storageDir = Directory('${appDir.path}/taskflow_files');

    // Create directory if it doesn't exist
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }

    return storageDir;
  }

  /// Upload file to local storage
  /// Returns the local file path
  Future<String> uploadFile({
    required String filePath,
    required String userId,
    String? customFileName,
  }) async {
    try {
      final File sourceFile = File(filePath);

      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist');
      }

      // Get storage directory
      final Directory storageDir = await _getStorageDirectory();

      // Create user-specific subdirectory
      final Directory userDir = Directory('${storageDir.path}/$userId');
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      // Generate filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(filePath);
      final String fileName = customFileName ?? 'file_$timestamp$extension';

      // Destination path
      final String destinationPath = '${userDir.path}/$fileName';

      // Copy file to local storage
      await sourceFile.copy(destinationPath);

      debugPrint('File saved to local storage: $destinationPath');
      return destinationPath;
    } catch (e) {
      debugPrint('Error uploading file to local storage: $e');
      rethrow;
    }
  }

  /// Upload task attachment
  Future<String> uploadTaskAttachment({
    required String filePath,
    required String taskId,
    required String userId,
  }) async {
    try {
      final Directory storageDir = await _getStorageDirectory();
      final Directory taskDir = Directory(
        '${storageDir.path}/task_attachments/$userId/$taskId',
      );

      if (!await taskDir.exists()) {
        await taskDir.create(recursive: true);
      }

      final File sourceFile = File(filePath);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(filePath);
      final String fileName = 'attachment_$timestamp$extension';
      final String destinationPath = '${taskDir.path}/$fileName';

      await sourceFile.copy(destinationPath);

      debugPrint('Task attachment saved: $destinationPath');
      return destinationPath;
    } catch (e) {
      debugPrint('Error uploading task attachment: $e');
      rethrow;
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required String filePath,
    required String userId,
  }) async {
    try {
      final Directory storageDir = await _getStorageDirectory();
      final Directory profileDir = Directory(
        '${storageDir.path}/profile_pictures/$userId',
      );

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final File sourceFile = File(filePath);
      final String extension = path.extension(filePath);
      final String fileName = 'profile$extension';
      final String destinationPath = '${profileDir.path}/$fileName';

      // Delete old profile picture if exists
      final File oldFile = File(destinationPath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      await sourceFile.copy(destinationPath);

      debugPrint('Profile picture saved: $destinationPath');
      return destinationPath;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Delete file from local storage
  Future<void> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('File deleted: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete task attachments
  Future<void> deleteTaskAttachments({
    required String taskId,
    required String userId,
  }) async {
    try {
      final Directory storageDir = await _getStorageDirectory();
      final Directory taskDir = Directory(
        '${storageDir.path}/task_attachments/$userId/$taskId',
      );

      if (await taskDir.exists()) {
        await taskDir.delete(recursive: true);
        debugPrint('Task attachments deleted for task: $taskId');
      }
    } catch (e) {
      debugPrint('Error deleting task attachments: $e');
      rethrow;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Get total storage used by the app (in bytes)
  Future<int> getTotalStorageUsed() async {
    try {
      final Directory storageDir = await _getStorageDirectory();
      int totalSize = 0;

      if (await storageDir.exists()) {
        await for (var entity in storageDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating storage used: $e');
      return 0;
    }
  }

  /// Clear all local storage
  Future<void> clearAllStorage() async {
    try {
      final Directory storageDir = await _getStorageDirectory();
      if (await storageDir.exists()) {
        await storageDir.delete(recursive: true);
        debugPrint('All local storage cleared');
      }
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }

  /// Get storage path for reference
  Future<String> getStoragePath() async {
    final Directory storageDir = await _getStorageDirectory();
    return storageDir.path;
  }
}
