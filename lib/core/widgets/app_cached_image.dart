import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.fallbackIcon = Icons.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final Widget errorWidget = Container(
      width: width,
      height: height,
      color: const Color(0xFF24201D),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: AppColors.primaryOrange,
          size: 45,
        ),
      ),
    );

    final Widget placeholderWidget = Container(
      width: width,
      height: height,
      color: const Color(0xFF1E1C1A),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
          ),
        ),
      ),
    );

    Widget imageWidget;
    final trimmed = imageUrl.trim();
    if (trimmed.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmed,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageWidget = CachedNetworkImage(
        imageUrl: trimmed,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => placeholderWidget,
        errorWidget: (context, url, error) => errorWidget,
      );
    } else if (trimmed.isNotEmpty) {
      imageWidget = Image.asset(
        'assets/images/recipes/$trimmed',
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      imageWidget = errorWidget;
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
