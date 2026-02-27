import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_flow/models/api_models/user_model.dart';
import 'package:auto_flow/constants/app_textstyles.dart';

import 'profile_avatar.dart';
import 'profile_editable_row.dart';

class ProfileHeroCard extends StatelessWidget {
  final Color primary;
  final String? bannerUrl;
  final bool isUploadingBanner;
  final String joinedYear;
  final VoidCallback onPickAndUploadBanner;

  final UserModel? user;
  final String? editingField;
  final bool isSaving;
  final TextEditingController nameController;
  final TextEditingController collegeController;
  final Function(String) onSaveField;
  final VoidCallback onCancelEdit;
  final Function(String) onSetEditingField;

  final String? avatarUrl;
  final String initials;
  final bool isUploadingAvatar;
  final VoidCallback onPickAndUploadAvatar;

  const ProfileHeroCard({
    super.key,
    required this.primary,
    required this.bannerUrl,
    required this.isUploadingBanner,
    required this.joinedYear,
    required this.onPickAndUploadBanner,
    required this.user,
    required this.editingField,
    required this.isSaving,
    required this.nameController,
    required this.collegeController,
    required this.onSaveField,
    required this.onCancelEdit,
    required this.onSetEditingField,
    required this.avatarUrl,
    required this.initials,
    required this.isUploadingAvatar,
    required this.onPickAndUploadAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          SizedBox(
            height: 110,
            child: GestureDetector(
              onTap: onPickAndUploadBanner,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: bannerUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 110,
                          placeholder: (_, __) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primary,
                                  primary.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primary,
                                  primary.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primary, primary.withValues(alpha: 0.6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                  // Upload overlay icon
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: isUploadingBanner
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                  ),

                  // Joined year pill
                  if (joinedYear.isNotEmpty)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          joinedYear,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Avatar overlapping banner
          Transform.translate(
            offset: const Offset(20, -36),
            child: ProfileAvatar(
              primary: primary,
              avatarUrl: avatarUrl,
              initials: initials,
              isUploadingAvatar: isUploadingAvatar,
              onPickAndUploadAvatar: onPickAndUploadAvatar,
            ),
          ),

          // Info content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileEditableRow(
                  field: 'name',
                  label: user?.name ?? '',
                  labelStyle: AppTextStyles.midHeader(context),
                  editLabel: 'Change Name',
                  controller: nameController,
                  primary: primary,
                  isEditing: editingField == 'name',
                  isSaving: isSaving,
                  onSave: () => onSaveField('name'),
                  onCancel: onCancelEdit,
                  onEdit: () => onSetEditingField('name'),
                ),
                const Divider(height: 20),

                // Email
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const Divider(height: 20),

                ProfileEditableRow(
                  field: 'collegeName',
                  label: user?.collegeName.isNotEmpty == true
                      ? user!.collegeName
                      : 'No institution specified',
                  labelStyle: AppTextStyles.subMidHeader(context).copyWith(
                    color: user?.collegeName.isNotEmpty == true
                        ? null
                        : Colors.grey[400],
                  ),
                  editLabel: 'Edit',
                  controller: collegeController,
                  primary: primary,
                  placeholder: 'University or College Name',
                  isEditing: editingField == 'collegeName',
                  isSaving: isSaving,
                  onSave: () => onSaveField('collegeName'),
                  onCancel: onCancelEdit,
                  onEdit: () => onSetEditingField('collegeName'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
