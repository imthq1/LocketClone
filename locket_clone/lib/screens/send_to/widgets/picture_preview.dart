import 'dart:io';
import 'package:flutter/material.dart';

class PicturePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onAddMessagePressed;
  final String? caption;

  const PicturePreview({
    super.key,
    required this.imagePath,
    this.onAddMessagePressed,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCaption = caption != null && caption!.isNotEmpty;
    final String displayText = hasCaption ? caption! : 'Thêm một tin nhắn';
    final FontWeight displayWeight = hasCaption
        ? FontWeight.w700
        : FontWeight.w500;

    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(imagePath), fit: BoxFit.cover),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onAddMessagePressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: displayWeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
