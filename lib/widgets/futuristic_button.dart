import 'package:flutter/material.dart';

class FuturisticButton extends StatelessWidget {
  final VoidCallback onTap;

  const FuturisticButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 220,
        height: 220,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xff00F5FF),

          boxShadow: const [
            BoxShadow(
              color: Color(0xff00F5FF),
              blurRadius: 60,
              spreadRadius: 12,
            ),
          ],
        ),

        child: const Center(
          child: Text(
            "TAP\nTO\nLOG",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
