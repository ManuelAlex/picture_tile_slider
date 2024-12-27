import 'package:flutter/material.dart';




class AssistiveTouchButton extends StatelessWidget {
  const AssistiveTouchButton({
    super.key,
    required this.onTap,
     this.size =40,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
        
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha:  0.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:  0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
    
          Container(
            height: size * 0.9,
            width: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha:  0.8),
                  Colors.white.withValues(alpha:  0.3),
                ],
                stops: const [0.3, 1],
              ),
            ),
          ),
        
          Container(
            height: size * 0.6,
            width: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:  0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class FloatingButton
 extends StatelessWidget {
  const FloatingButton
  ({super.key, required this.onTap,required this.onDragEnd});
    final VoidCallback onTap;
    final ValueChanged<Offset> onDragEnd;

  @override
  Widget build(BuildContext context) {
    final Widget child =AssistiveTouchButton(onTap: onTap, size: 40);
    return  Draggable(
              feedback:child,
              childWhenDragging:const SizedBox.shrink(),
                onDragEnd: (details) =>onDragEnd(details.offset),
              child: child);
  }
}