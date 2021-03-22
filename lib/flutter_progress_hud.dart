library flutter_progress_hud;

import 'package:flutter/material.dart';

class ProgressHUD extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Color indicatorColor;
  final Widget? indicatorWidget;
  final Color backgroundColor;
  final Radius backgroundRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  ProgressHUD({
    required this.child,
    required this.visible,
    this.indicatorColor = Colors.white,
    this.indicatorWidget,
    this.backgroundColor = Colors.black54,
    this.backgroundRadius = const Radius.circular(8.0),
    this.borderColor = Colors.white,
    this.borderWidth = 0.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  _ProgressHUDState createState() => _ProgressHUDState();
}

class _ProgressHUDState extends State<ProgressHUD>
    with SingleTickerProviderStateMixin {
  bool _barrierVisible = false;

  late AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );

  late Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  void _show() {
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    _animation.addStatusListener((status) {
      if (mounted) {
        setState(() {
          _barrierVisible = status != AnimationStatus.dismissed;
        });
      }
    });

    super.initState();

    _show();
  }

  @override
  void didUpdateWidget(ProgressHUD oldWidget) {
    super.didUpdateWidget(oldWidget);

    _show();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      IgnorePointer(
        ignoring: !widget.visible,
        child: TickerMode(
          enabled: widget.visible,
          child: FadeTransition(
            opacity: _animation,
            child: Stack(children: [
              Visibility(
                visible: _barrierVisible,
                child: ModalBarrier(
                  color: Colors.transparent,
                  dismissible: false,
                ),
              ),
              Center(child: _buildProgress()),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildProgress() {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.all(widget.backgroundRadius),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.indicatorWidget ?? _buildDefaultIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIndicator() {
    return Container(
      width: 40.0,
      height: 40.0,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation(widget.indicatorColor),
      ),
    );
  }
}
