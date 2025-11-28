/// Local Authentication Service
///
/// Handles user authentication using local SQLite database
/// Password hashing for security

import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/sqlite_database_helper.dart';

class LocalAuthService {
  static final LocalAuthService instance = LocalAuthService._init();
  
  String? _currentUserId;
  Map<String, dynamic>? _currentUser;

  LocalAuthService._init();

  String? get currentUserId => _currentUserId;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register new user (Student)
  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
    required String studentId,
    String? major,
    int? semester,
    String? contactNumber,
  }) async {
    try {
      final db = SQLiteDatabaseHelper.instance;

      // Check if email already exists
      final existingEmail = await db.getUserByEmail(email);
      if (existingEmail != null) {
        throw Exception('Email already registered');
      }

      // Check if student ID already exists
      final existingStudentId = await db.getUserByStudentId(studentId);
      if (existingStudentId != null) {
        throw Exception('Student ID already registered');
      }

      // Generate user ID
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create user data
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'password': _hashPassword(password),
        'role': 'student', // Default role for registerUser
        'student_id': studentId,
        'major': major,
        'semester': semester,
        'contact_number': contactNumber,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert into database
      await db.createUser(userData);

      // Remove password from returned data
      userData.remove('password');
      
      print('User registered successfully: $email');
      return userData;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  /// Login user with email or student ID
  Future<Map<String, dynamic>?> loginUser(String emailOrStudentId, String password) async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      Map<String, dynamic>? user;

      // Try to find by email first
      if (emailOrStudentId.contains('@')) {
        user = await db.getUserByEmail(emailOrStudentId);
      } else {
        // Try to find by student ID
        user = await db.getUserByStudentId(emailOrStudentId);
      }

      if (user == null) {
        throw Exception('User not found');
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user['password'] != hashedPassword) {
        throw Exception('Invalid password');
      }

      // Set current user
      _currentUserId = user['id'];
      _currentUser = Map<String, dynamic>.from(user);
      _currentUser!.remove('password'); // Don't keep password in memory

      print('User logged in successfully: ${user['email']}');
      return _currentUser;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _currentUserId = null;
    _currentUser = null;
    print('User logged out');
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      final user = await db.getUserById(userId);
      if (user != null) {
        user.remove('password'); // Don't expose password
      }
      return user;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      final users = await db.getAllUsers();
      // Remove passwords
      for (var user in users) {
        user.remove('password');
      }
      return users;
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  /// Update user profile
  Future<void> updateUser({
    required String userId,
    String? name,
    String? avatarUrl,
    String? major,
    int? semester,
    String? contactNumber,
  }) async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (major != null) updates['major'] = major;
      if (semester != null) updates['semester'] = semester;
      if (contactNumber != null) updates['contact_number'] = contactNumber;

      if (updates.isNotEmpty) {
        await db.updateUser(userId, updates);
        
        // Update current user if it's the same user
        if (_currentUserId == userId && _currentUser != null) {
          _currentUser!.addAll(updates);
        }
        
        print('User updated successfully');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      final user = await db.getUserById(userId);

      if (user == null) {
        throw Exception('User not found');
      }

      // Verify old password
      final hashedOldPassword = _hashPassword(oldPassword);
      if (user['password'] != hashedOldPassword) {
        throw Exception('Invalid old password');
      }

      // Update to new password
      final hashedNewPassword = _hashPassword(newPassword);
      await db.updateUser(userId, {'password': hashedNewPassword});

      print('Password changed successfully');
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      final user = await db.getUserByEmail(email);
      return user != null;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  /// Check if student ID exists
  Future<bool> studentIdExists(String studentId) async {
    try {
      final db = SQLiteDatabaseHelper.instance;
      final user = await db.getUserByStudentId(studentId);
      return user != null;
    } catch (e) {
      print('Error checking student ID: $e');
      return false;
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _currentUserId != null;
  }

  /// All users are students in this version
  bool isStudent() {
    return isLoggedIn();
  }
}

