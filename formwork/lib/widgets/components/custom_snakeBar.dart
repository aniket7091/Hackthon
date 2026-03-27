import 'package:flutter/material.dart';

class AppOverlaySnackBar {
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.green,
    IconData icon = Icons.check_circle,
    Color textColor = Colors.white,
    double width = 300,
    double height = 40,
    bool isTop = true,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _AnimatedSnackBar(
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          textColor: textColor,
          width: width,
          height: height,
          isTop: isTop,
          onDismiss: () => overlayEntry.remove(),
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Color textColor;
  final double width;
  final double height;
  final bool isTop;
  final VoidCallback onDismiss;

  const _AnimatedSnackBar({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.textColor,
    required this.width,
    required this.height,
    required this.isTop,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    slideAnimation = Tween<Offset>(
      begin: widget.isTop ? Offset(0, -1) : Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(controller);

    controller.forward();

    Future.delayed(Duration(seconds: 2), () async {
      await controller.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.isTop ? 60 : null,
      bottom: widget.isTop ? null : 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.textColor, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
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