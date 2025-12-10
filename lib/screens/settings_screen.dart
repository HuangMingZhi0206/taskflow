import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final ThemeService themeService;
  final PreferencesService preferencesService;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.themeService,
    required this.preferencesService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.user['name']);
    _loadProfileImage();
  }

  late TextEditingController _nameController;
  bool _isEditingName = false;
  bool _isUpdatingName = false;

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Name cannot be empty');
      return;
    }

    setState(() => _isUpdatingName = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user['id'])
          .update({'name': _nameController.text.trim()});

      if (mounted) {
        setState(() {
          widget.user['name'] = _nameController.text.trim();
          _isEditingName = false;
        });

        _showSnackBar('Name updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update name: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Center(
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textLight,
              tabs: const [
                Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
                Tab(icon: Icon(Icons.palette_outlined), text: 'Appearance'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(isDark), _buildAppearanceTab(isDark)],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        showFab: false,
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              '/dashboard',
              arguments: widget.user,
            );
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/schedule',
              arguments: widget.user,
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/focus',
              arguments: widget.user,
            );
          }
        },
        onFabTap: () {},
      ),
    );
  }

  // ===== PROFILE TAB =====
  Widget _buildProfileTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Text(
                            widget.user['name'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isEditingName
                  ? Container(
                      width: 200,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.user['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () {
                            setState(() {
                              _nameController.text = widget.user['name'];
                              _isEditingName = true;
                            });
                          },
                          color: AppTheme.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
              if (_isEditingName)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingName = false;
                          _nameController.text = widget.user['name'];
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    _isUpdatingName
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : FilledButton(
                            onPressed: _updateName,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Save'),
                          ),
                  ],
                ),
              if (!_isEditingName) const SizedBox(height: 4),
              Text(
                widget.user['email'],
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.user['role'].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildSectionHeader('Account Information'),
        if (widget.user['student_id'] != null &&
            widget.user['student_id'].toString().isNotEmpty)
          _buildInfoTile(
            Icons.badge_outlined,
            'Student ID',
            widget.user['student_id'],
            isDark,
          ),
        _buildInfoTile(
          Icons.email_outlined,
          'Email',
          widget.user['email'],
          isDark,
        ),
        const SizedBox(height: 24),

        _buildActionTile(
          Icons.lock_outline,
          'Change Password',
          'Update your account password',
          () {
            _showChangePasswordDialog(context);
          },
          isDark,
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          Icons.logout,
          'Logout',
          'Sign out of your account',
          () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.urgent,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
            if (confirm == true && mounted) {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            }
          },
          isDark,
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            'Made for Productivity',
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ===== APPEARANCE TAB =====
  Widget _buildAppearanceTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionHeader('Theme Mode'),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.textLight.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _buildThemeOption(
                ThemeMode.light,
                'Light Mode',
                'Bright and clear',
                Icons.light_mode_outlined,
              ),
              Divider(
                height: 1,
                color: AppTheme.textLight.withValues(alpha: 0.1),
              ),
              _buildThemeOption(
                ThemeMode.dark,
                'Dark Mode',
                'Easy on the eyes',
                Icons.dark_mode_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            'Made for Productivity',
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ===== HELPER WIDGETS =====
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => widget.themeService.setThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            if (widget.themeService.themeMode == mode)
              const Icon(Icons.check, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textLight.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textLight, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textLight.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppTheme.textLight),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: AppTheme.textLight,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Change Password',
              style: TextStyle(fontSize: 18),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: !showCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    isDense: true,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => showCurrentPassword = !showCurrentPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    isDense: true,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => showNewPassword = !showNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    isDense: true,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => showConfirmPassword = !showConfirmPassword,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FilledButton(
                      onPressed: () async {
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          _showSnackBar('New passwords do not match');
                          return;
                        }
                        if (newPasswordController.text.length < 6) {
                          _showSnackBar(
                            'Password must be at least 6 characters',
                          );
                          return;
                        }

                        setState(() => isLoading = true);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final cred = EmailAuthProvider.credential(
                              email: user.email!,
                              password: currentPasswordController.text,
                            );

                            await user.reauthenticateWithCredential(cred);
                            await user.updatePassword(
                              newPasswordController.text,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              _showSnackBar('Password changed successfully');
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          if (context.mounted) {
                            _showSnackBar(
                              e.message ?? 'Failed to update password',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showSnackBar('An error occurred');
                          }
                        } finally {
                          if (mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                      child: const Text('Change'),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${widget.user['id']}');
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() {
            _profileImage = file;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${widget.user['id']}', image.path);

        setState(() {
          _profileImage = File(image.path);
        });

        _showSnackBar('Profile photo updated successfully');
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }
}
