import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        icon: Image.asset(
          'lib/assets/google_logo.png',
          height: 24.0,
          width: 24.0,
        ),
        label: const Text(
          'Tiếp tục với Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
