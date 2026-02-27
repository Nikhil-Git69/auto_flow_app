import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final Color primary;
  final String? avatarUrl;
  final String initials;
  final bool isUploadingAvatar;
  final VoidCallback onPickAndUploadAvatar;

  const ProfileAvatar({
    super.key,
    required this.primary,
    required this.avatarUrl,
    required this.initials,
    required this.isUploadingAvatar,
    required this.onPickAndUploadAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onPickAndUploadAvatar,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: isUploadingAvatar
                ? const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  )
                : avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        // Camera badge
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onPickAndUploadAvatar,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
