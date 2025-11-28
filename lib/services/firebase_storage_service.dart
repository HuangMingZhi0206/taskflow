import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorageService instance = FirebaseStorageService._init();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseStorageService._init();

  // Upload user avatar
  Future<String?> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      Reference ref = _storage.ref().child('avatars/$userId/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // Upload task attachment
  Future<String?> uploadTaskAttachment({
    required String taskId,
    required File file,
  }) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      Reference ref = _storage.ref().child('task_attachments/$taskId/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading attachment: $e');
      return null;
    }
  }

  // Upload comment attachment
  Future<String?> uploadCommentAttachment({
    required String taskId,
    required String commentId,
    required File file,
  }) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      Reference ref = _storage.ref().child('comment_attachments/$taskId/$commentId/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading comment attachment: $e');
      return null;
    }
  }

  // Delete file by URL
  Future<bool> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Delete all user avatars
  Future<void> deleteUserAvatars(String userId) async {
    try {
      Reference ref = _storage.ref().child('avatars/$userId');
      ListResult result = await ref.listAll();

      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      print('Error deleting user avatars: $e');
    }
  }

  // Delete all task attachments
  Future<void> deleteTaskAttachments(String taskId) async {
    try {
      Reference ref = _storage.ref().child('task_attachments/$taskId');
      ListResult result = await ref.listAll();

      for (Reference fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      print('Error deleting task attachments: $e');
    }
  }

  // Get file size
  Future<int?> getFileSize(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      FullMetadata metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  // Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      FullMetadata metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
      };
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }
}

