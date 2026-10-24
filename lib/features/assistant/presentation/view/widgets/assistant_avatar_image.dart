import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Persistent disk + memory cache for the assistant artwork used across screens.
class AssistantAvatarImage extends StatelessWidget {
  const AssistantAvatarImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
  });

  final String url;
  final double width;
  final double height;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      memCacheWidth: (width * 3).round(),
      maxWidthDiskCache: 768,
      useOldImageOnUrlChange: true,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
