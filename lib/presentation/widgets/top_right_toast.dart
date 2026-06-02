import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Lightweight toast shown at the top-right using an [OverlayEntry].
///
/// Use this when we want a "notification" style message (not a bottom SnackBar).
void showTopRightToast(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _TopRightToastOverlay(
      message: message,
      isError: isError,
      duration: duration,
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _TopRightToastOverlay extends StatefulWidget {
  const _TopRightToastOverlay({
    required this.message,
    required this.isError,
    required this.duration,
    required this.onDone,
  });

  final String message;
  final bool isError;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_TopRightToastOverlay> createState() => _TopRightToastOverlayState();
}

class _TopRightToastOverlayState extends State<_TopRightToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0.16, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topInset + 12,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                      size: 18,
                      color: widget.isError ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

