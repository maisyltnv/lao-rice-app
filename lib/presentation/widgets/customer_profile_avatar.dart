import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/profile_avatar_placeholder.dart';

class CustomerProfileAvatar extends StatelessWidget {
  const CustomerProfileAvatar({
    super.key,
    required this.radius,
    required this.isSignedIn,
    required this.displayName,
    this.localPath,
    this.onTap,
    this.showCameraBadge = false,
  });

  final double radius;
  final bool isSignedIn;
  final String displayName;
  final String? localPath;
  final VoidCallback? onTap;
  final bool showCameraBadge;

  String get _initials {
    final parts = displayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts.first.characters.first}${parts[1].characters.first}';
  }

  bool get _hasLocal =>
      localPath != null && localPath!.isNotEmpty && File(localPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final avatar = _hasLocal
        ? CircleAvatar(radius: radius, backgroundImage: FileImage(File(localPath!)))
        : ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: Image.asset(
                ProfileAvatarPlaceholder.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(size),
              ),
            ),
          );

    final content = showCameraBadge && onTap != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Icon(Icons.camera_alt_rounded, size: radius * 0.34, color: const Color(0xFF7C5C1E)),
                ),
              ),
            ],
          )
        : avatar;

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 2),
        ),
        child: content,
      ),
    );
  }

  Widget _fallback(double size) {
    final hasInitials = _initials.isNotEmpty;
    return Container(
      width: size,
      height: size,
      color: Colors.white.withValues(alpha: 0.22),
      alignment: Alignment.center,
      child: hasInitials
          ? Text(
              _initials,
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: radius * 0.65,
                fontWeight: FontWeight.w800,
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: radius * 1.1,
              color: Colors.white.withValues(alpha: 0.95),
            ),
    );
  }
}
