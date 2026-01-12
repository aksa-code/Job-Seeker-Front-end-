import 'package:flutter/material.dart';

class AlertMessage {
  void showAlert(
    BuildContext context,
    String? message,
    bool status, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showModernAlert(context, message ?? "", status, null, duration);
  }

  void showAlertWithTitle(
    BuildContext context, {
    required String message,
    required bool status,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showModernAlert(context, message, status, title, duration);
  }

  void _showModernAlert(
    BuildContext context,
    String message,
    bool status,
    String? title,
    Duration duration,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ModernAlertWidget(
        message: message,
        isSuccess: status,
        title: title,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}

class _ModernAlertWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final String? title;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ModernAlertWidget({
    required this.message,
    required this.isSuccess,
    this.title,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ModernAlertWidget> createState() => _ModernAlertWidgetState();
}

class _ModernAlertWidgetState extends State<_ModernAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto dismiss with reverse animation
    final dismissTime = widget.duration - const Duration(milliseconds: 300);
    Future.delayed(dismissTime, () {
      if (mounted) _controller.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isSuccess
        ? [const Color(0xFF10B981), const Color(0xFF059669)]
        : [const Color(0xFFEF4444), const Color(0xFFDC2626)];

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _handleDismiss,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title ??
                                (widget.isSuccess ? "Success" : "Error"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
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

extension AlertMessageExtension on BuildContext {
  void showSuccessAlert(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    AlertMessage().showAlertWithTitle(
      this,
      message: message,
      status: true,
      title: title,
      duration: duration,
    );
  }

  void showErrorAlert(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    AlertMessage().showAlertWithTitle(
      this,
      message: message,
      status: false,
      title: title,
      duration: duration,
    );
  }
}