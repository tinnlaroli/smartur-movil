import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            Hero(
              tag: heroTag,
              child: SizedBox.expand(
                child: Image.network(
                  heroImageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Dark overlay for legibility
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.38)),
            ),
            SafeArea(
              child: Stack(
                children: [
                  // Top actions
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border, color: Colors.white),
                    ),
                  ),

                  // Right mosaic
                  Positioned(
                    top: 140,
                    right: 16,
                    child: _RightMosaic(galleryUrls: galleryUrls),
                  ),

                  // Main content
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RatingPill(rating: rating),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'CalSans',
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                locationLine,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tabs + content inside glass card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TabBar(
                                  isScrollable: true,
                                  indicatorColor: SmarturStyle.orange,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white70,
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                  tabs: const [
                                    Tab(text: 'Historia'),
                                    Tab(text: 'Ubicación'),
                                    Tab(text: 'Gastronomía'),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 130,
                                  child: TabBarView(
                                    children: [
                                      _TabText(
                                        text: subtitle,
                                      ),
                                      const _TabText(
                                        text:
                                            'Mapa y puntos clave para visitar. (Placeholder para R4: pins + rutas)',
                                      ),
                                      const _TabText(
                                        text:
                                            'Platillos típicos y cafés recomendados. (Placeholder)',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // CTA
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SmarturStyle.orange,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Ver Guías Locales',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SmarturStyle.orange.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SmarturStyle.orange.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: SmarturStyle.orange),
          const SizedBox(width: 6),
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
    final items = galleryUrls.take(3).toList();
    final remaining = (galleryUrls.length - items.length);

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _MiniThumb(url: items[i], size: i == 0 ? 56 : 48),
          const SizedBox(height: 10),
        ],
        if (remaining > 0)
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: size,
        height: size,
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
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          height: 1.35,
          color: Colors.white70,
        ),
      ),
    );
  }
}

