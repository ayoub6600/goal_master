import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loading: grey shapes of the coming content with a soft shimmer,
/// instead of a spinning circle. Wrap any layout of [SkeletonBox]es in
/// [Skeleton], or use the ready-made shapes below.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) return child;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE7ECE6),
      highlightColor: const Color(0xFFF6F8F5),
      period: const Duration(milliseconds: 1300),
      child: child,
    );
  }
}

/// One grey block; [width] null fills the row.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECE6),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// A row like a notification / transaction / booking line: icon, two lines,
/// optional trailing value.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key, this.trailing = true, this.leadingSize = 44});
  final bool trailing;
  final double leadingSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SkeletonBox(height: leadingSize, width: leadingSize, radius: 12),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: double.infinity),
                SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.55,
                  child: SkeletonBox(height: 12),
                ),
              ],
            ),
          ),
          if (trailing) ...[
            const SizedBox(width: 12),
            const SkeletonBox(height: 14, width: 48),
          ],
        ],
      ),
    );
  }
}

/// A card with a picture on top and two lines under it (venues, offers).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.imageHeight = 140, this.width});
  final double imageHeight;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonBox(height: imageHeight, width: double.infinity, radius: 16),
          const SizedBox(height: 10),
          const SkeletonBox(height: 14, width: 160),
          const SizedBox(height: 8),
          const SkeletonBox(height: 12, width: 100),
        ],
      ),
    );
  }
}

/// A whole list loading: [count] rows of [SkeletonListTile].
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.trailing = true,
    this.shrinkWrap = false,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final bool trailing;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    // Shrink-wrapped: a plain column, not a scroll view — it is often placed
    // where the parent measures its child (a paged list's first-page
    // indicator), which a nested viewport cannot answer.
    if (shrinkWrap) {
      return Skeleton(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                SkeletonListTile(trailing: trailing),
              ],
            ],
          ),
        ),
      );
    }
    return Skeleton(
      child: ListView.separated(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, __) => SkeletonListTile(trailing: trailing),
      ),
    );
  }
}

/// A list of [SkeletonCard]s (vertical feed of venues / bookings).
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({
    super.key,
    this.count = 3,
    this.imageHeight = 140,
    this.padding = const EdgeInsets.all(16),
    this.shrinkWrap = false,
  });

  final int count;
  final double imageHeight;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Skeleton(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                SkeletonCard(imageHeight: imageHeight),
              ],
            ],
          ),
        ),
      );
    }
    return Skeleton(
      child: ListView.separated(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, __) => SkeletonCard(imageHeight: imageHeight),
      ),
    );
  }
}

/// A horizontal strip of cards (home sections).
class SkeletonCardStrip extends StatelessWidget {
  const SkeletonCardStrip({
    super.key,
    this.height = 210,
    this.cardWidth = 220,
    this.count = 3,
  });

  final double height;
  final double cardWidth;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Skeleton(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) =>
              SkeletonCard(width: cardWidth, imageHeight: height - 60),
        ),
      ),
    );
  }
}

/// A details page: a big header block and some lines.
class SkeletonDetails extends StatelessWidget {
  const SkeletonDetails({super.key, this.headerHeight = 200});
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SkeletonBox(height: headerHeight, width: double.infinity, radius: 18),
          const SizedBox(height: 18),
          const SkeletonBox(height: 20, width: 200),
          const SizedBox(height: 12),
          for (var i = 0; i < 5; i++) ...[
            const SkeletonListTile(leadingSize: 28),
          ],
          const SizedBox(height: 12),
          const SkeletonBox(height: 48, width: double.infinity, radius: 14),
        ],
      ),
    );
  }
}

/// Fills whatever space it is given with a shimmering block — for image
/// placeholders (a picture loading) instead of a spinner in the middle.
class SkeletonFill extends StatelessWidget {
  const SkeletonFill({super.key, this.radius = 0});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE7ECE6),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A small, thin spinner for the places that really wait on an action
/// (a button submitting, an overlay while paying) — never for content.
class SoftSpinner extends StatelessWidget {
  const SoftSpinner({super.key, this.size = 22, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        strokeCap: StrokeCap.round,
        color: color ?? const Color(0xFF418946),
      ),
    );
  }
}
