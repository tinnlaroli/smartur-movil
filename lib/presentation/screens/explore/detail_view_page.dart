import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:smartur/l10n/app_localizations.dart';
import '../../../core/theme/style_guide.dart';

class DetailViewPage extends StatelessWidget {
  final String title;
  final String heroTag;
  final String heroImageUrl;
  final String subtitle;
  final String locationLine;
  final double rating;
  final List<String> galleryUrls;

  const DetailViewPage({
    super.key,
    required this.title,
    required this.heroTag,
    required this.heroImageUrl,
    required this.subtitle,
    required this.locationLine,
    required this.rating,
    required this.galleryUrls,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            // Hero background image
            Hero(
              tag: heroTag,
              child: SizedBox.expand(
                child: Image.network(
                  heroImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey.shade900,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: Colors.white38, size: 48),
                  ),
                ),
              ),
            ),

            // Dark gradient overlay
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.3, 0.7, 1.0],
                    colors: [
                      Color(0x30000000),
                      Color(0x10000000),
                      Color(0x90000000),
                      Color(0xDD000000),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Stack(
                children: [
                  // Top row — back + bookmark
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _GlassCircle(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _GlassCircle(
                      onTap: () {},
                      child: const Icon(Icons.bookmark_border_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),

                  // Right mosaic thumbnails
                  if (galleryUrls.length > 1)
                    Positioned(
                      top: 130,
                      right: 16,
                      child: _RightMosaic(galleryUrls: galleryUrls),
                    ),

                  // Main content — bottom sheet style
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomContent(
                      title: title,
                      locationLine: locationLine,
                      rating: rating,
                      subtitle: subtitle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════

class _GlassCircle extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassCircle({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            color: Colors.white.withValues(alpha: 0.12),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Bottom content with glass card ──

class _BottomContent extends StatelessWidget {
  final String title;
  final String locationLine;
  final double rating;
  final String subtitle;

  const _BottomContent({
    required this.title,
    required this.locationLine,
    required this.rating,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating + location row
              Row(
                children: [
                  _RatingPill(rating: rating),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'CalSans',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              // Tabs
              TabBar(
                isScrollable: true,
                indicatorColor: SmarturStyle.orange,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                dividerHeight: 0,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: l10n.tabHistory),
                  Tab(text: l10n.tabLocation),
                  Tab(text: l10n.tabGastronomy),
                  Tab(text: l10n.tabAiSummary),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 110,
                child: TabBarView(
                  children: [
                    _TabText(text: subtitle),
                    _TabText(text: l10n.tabLocationPlaceholder),
                    _TabText(text: l10n.tabGastronomyPlaceholder),
                    _TabText(text: l10n.tabAiPlaceholder),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CTA row: price + button
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.fromPrice,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        l10n.free,
                        style: TextStyle(
                          fontFamily: 'CalSans',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SmarturStyle.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: Text(
                        l10n.createOneDayRoute,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable small widgets ──

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SmarturStyle.orange.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SmarturStyle.orange.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: SmarturStyle.orange),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RightMosaic extends StatelessWidget {
  final List<String> galleryUrls;
  const _RightMosaic({required this.galleryUrls});

  @override
  Widget build(BuildContext context) {
    final items = galleryUrls.skip(1).take(3).toList();
    final remaining = (galleryUrls.length - 1 - items.length).clamp(0, 999);

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _MiniThumb(url: items[i], size: i == 0 ? 54 : 46),
          const SizedBox(height: 10),
        ],
        if (remaining > 0)
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Text(
              '+$remaining',
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniThumb extends StatelessWidget {
  final String url;
  final double size;
  const _MiniThumb({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
      ),
      child: ClipOval(
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  final String text;
  const _TabText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
