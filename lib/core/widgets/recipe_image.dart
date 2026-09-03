import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class RecipeImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const RecipeImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();

    final errorWidget = Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: const Color(0xFF211B17),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          color: AppColors.primaryOrange,
          size: 42,
        ),
      ),
    );

    Widget imageContent;

    if (trimmed.startsWith('assets/')) {
      imageContent = Image.asset(
        trimmed,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageContent = Image.network(
        trimmed,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else if (trimmed.startsWith('uploads/') || trimmed.startsWith('/uploads/')) {
      final serverUrl = '${AppConstants.apiBaseUrl}/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
      imageContent = Image.network(
        serverUrl,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else if (trimmed.startsWith('/') || trimmed.startsWith('file://')) {
      final file = File(trimmed.replaceFirst('file://', ''));
      imageContent = Image.file(
        file,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else if (trimmed.isNotEmpty) {
      // If relative filename passed without assets/ prefix
      final fullPath = 'assets/images/recipes/$trimmed';
      imageContent = Image.asset(
        fullPath,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      imageContent = errorWidget;
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }
}
