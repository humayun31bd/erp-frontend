import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HoverTiltCard extends StatefulWidget {
  final Widget child;
  final double depth;

  const HoverTiltCard({
    super.key,
    required this.child,
    this.depth = 20.0,
  });

  @override
  State<HoverTiltCard> createState() => _HoverTiltCardState();
}

class _HoverTiltCardState extends State<HoverTiltCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  Offset _tilt = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerHoverEvent event) {
    if (!mounted) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.globalToLocal(event.position);

    // Calculate rotation between -1 and 1
    final dx = (position.dx - size.width / 2) / (size.width / 2);
    final dy = (position.dy - size.height / 2) / (size.height / 2);

    setState(() {
      // Tilt logic: moving right tilts around Y axis, moving down tilts around X axis
      _tilt = Offset(dy, -dx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _tilt = Offset.zero;
        });
        _controller.reverse();
      },
      onHover: _onPointerMove,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final tiltAmount = 0.05 * _animation.value;
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(_tilt.dx * tiltAmount)
            ..rotateY(_tilt.dy * tiltAmount);

          return Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        )
                      ]
                    : [],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
