import 'dart:convert';
import 'dart:io';

import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/profile/service/profile_service.dart';
import 'package:auto_flow/models/api_models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:auto_flow/features/profile/widgets/profile_hero_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  final _imagePicker = ImagePicker();

  UserModel? _user;
  bool _isLoadingProfile = true;
  bool _isUploadingAvatar = false;
  bool _isUploadingBanner = false;

  // Inline editing
  String? _editingField; // 'name' | 'collegeName' | null
  late TextEditingController _nameController;
  late TextEditingController _collegeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _collegeController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  // ─── Load user from local storage, then refresh from network ────────────────
  Future<void> _loadUser() async {
    try {
      final userDataStr = await _storage.read(key: 'userData');
      if (userDataStr != null) {
        final local = UserModel.fromJson(jsonDecode(userDataStr));
        setState(() {
          _user = local;
          _nameController.text = local.name;
          _collegeController.text = local.collegeName;
          _isLoadingProfile = false;
        });
      }
      // Refresh from network
      final userId = await _storage.read(key: 'userId');
      if (userId != null) {
        final result = await ProfileService.getProfile(userId);
        if (result['success'] == true && mounted) {
          final fresh = result['data'] as UserModel;
          await ProfileService.saveUserLocally(fresh);
          setState(() {
            _user = fresh;
            _nameController.text = fresh.name;
            _collegeController.text = fresh.collegeName;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // ─── Avatar ──────────────────────────────────────────────────────────────────
  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return; // Prevent double taps

    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    setState(() => _isUploadingAvatar = true);

    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
    } on PlatformException catch (e) {
      debugPrint('Image picker error: $e');
    } catch (e) {
      debugPrint('Unknown image picker error: $e');
    }

    if (picked == null || !mounted) {
      setState(() => _isUploadingAvatar = false);
      return;
    }

    setState(() => _isUploadingAvatar = true);

    final result = await ProfileService.uploadAvatar(userId, File(picked.path));

    if (!mounted) return;

    if (result['success'] == true) {
      final updated = _user!.copyWith(logoUrl: result['logoUrl'] as String?);
      await ProfileService.saveUserLocally(updated);
      setState(() => _user = updated);
      _showSnack('Profile picture updated!', Colors.green);
    } else {
      _showSnack(result['message'] ?? 'Upload failed', Colors.red);
    }

    setState(() => _isUploadingAvatar = false);
  }

  // ─── Banner ───────────────────────────────────────────────────────────────────
  Future<void> _pickAndUploadBanner() async {
    if (_isUploadingBanner) return;

    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
    } catch (e) {
      debugPrint('Banner picker error: $e');
    }

    if (picked == null || !mounted) return;

    setState(() => _isUploadingBanner = true);

    final result = await ProfileService.uploadBanner(userId, File(picked.path));

    if (!mounted) return;

    if (result['success'] == true) {
      final updated = _user!.copyWith(
        bannerUrl: result['bannerUrl'] as String?,
      );
      await ProfileService.saveUserLocally(updated);
      setState(() => _user = updated);
      _showSnack('Banner updated!', Colors.green);
    } else {
      _showSnack(result['message'] ?? 'Upload failed', Colors.red);
    }

    setState(() => _isUploadingBanner = false);
  }

  // ─── Save field (name or collegeName) ────────────────────────────────────────
  Future<void> _saveField(String field) async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    setState(() => _isSaving = true);

    final result = await ProfileService.updateProfile(
      userId,
      name: field == 'name' ? _nameController.text.trim() : null,
      collegeName: field == 'collegeName'
          ? _collegeController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final updated = result['data'] as UserModel;
      // Preserve local fields that API might not return
      final merged = _user!.copyWith(
        name: updated.name,
        collegeName: updated.collegeName,
      );
      await ProfileService.saveUserLocally(merged);
      setState(() {
        _user = merged;
        _editingField = null;
      });
      _showSnack('Saved!', Colors.green);
    } else {
      _showSnack(result['message'] ?? 'Failed to save', Colors.red);
    }

    setState(() => _isSaving = false);
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _user?.name ?? '';
      _collegeController.text = _user?.collegeName ?? '';
      _editingField = null;
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Banner URL ──────────────────────────────────────────────────────────────
  String? _bannerUrl() {
    final url = _user?.bannerUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiUrl.baseUrl}$url';
  }

  // ─── Avatar URL ──────────────────────────────────────────────────────────────
  String? _avatarUrl() {
    final url = _user?.logoUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiUrl.baseUrl}$url';
  }

  String _initials() {
    final name = _user?.name ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  String _joinedYear() {
    final createdAt = _user?.createdAt;
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    return 'Joined ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Hero Card (Banner, Avatar, Name, College)
                    ProfileHeroCard(
                      primary: primary,
                      bannerUrl: _bannerUrl(),
                      isUploadingBanner: _isUploadingBanner,
                      joinedYear: _joinedYear(),
                      onPickAndUploadBanner: _pickAndUploadBanner,
                      user: _user,
                      editingField: _editingField,
                      isSaving: _isSaving,
                      nameController: _nameController,
                      collegeController: _collegeController,
                      onSaveField: _saveField,
                      onCancelEdit: _cancelEdit,
                      onSetEditingField: (field) =>
                          setState(() => _editingField = field),
                      avatarUrl: _avatarUrl(),
                      initials: _initials(),
                      isUploadingAvatar: _isUploadingAvatar,
                      onPickAndUploadAvatar: _pickAndUploadAvatar,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
