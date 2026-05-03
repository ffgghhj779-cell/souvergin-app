import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/visa.dart';
import '../../core/services/analytics_service.dart';
import '../../core/l10n/app_strings.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/app_buttons.dart';

/// Visa card used in both the home featured grid and visas list.
///
/// PHASE 2 PERFORMANCE NOTES:
/// - ClipRRect removed → replaced with Material(clipBehavior: Clip.antiAlias)
///   which uses GPU stencil clipping instead of the expensive saveLayer call.
/// - Shadow lives in a DecoratedBox OUTSIDE the clip so it never triggers
///   saveLayer — this was the #1 GPU bottleneck in the original card.
/// - Wrapped in RepaintBoundary → card gets its own compositing layer,
///   so a parent rebuild never repaints this card.
/// - Hero tag added around the image → seamless shared-element transition
///   to VisaDetailScreen with zero extra code on the destination side.
/// - Press-scale (0.97) added via AnimationController for tactile depth.
class VisaCard extends StatefulWidget {
  final Visa visa;
  final String locale;
  final VoidCallback? onTap;
  final bool isFeatured;

  const VisaCard({
    super.key,
    required this.visa,
    required this.locale,
    this.onTap,
    this.isFeatured = false,
  });

  @override
  State<VisaCard> createState() => _VisaCardState();
}

class _VisaCardState extends State<VisaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onTap == null) return;
          HapticFeedback.lightImpact();
          _pressCtrl.forward();
        },
        onTapUp: (_) {
          _pressCtrl.reverse();
          if (widget.onTap != null) {
            AnalyticsService.visaViewed(widget.visa.slug);
            widget.onTap!();
          }
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: _CardContent(
            visa: widget.visa,
            locale: widget.locale,
            isFeatured: widget.isFeatured,
          ),
        ),
      ),
    );
  }
}

// ── Card visual content (separated so it's const-constructible) ──────────────
class _CardContent extends StatelessWidget {
  final Visa visa;
  final String locale;
  final bool isFeatured;

  const _CardContent({
    required this.visa,
    required this.locale,
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    // ── The shadow lives OUTSIDE the clip in a DecoratedBox. ─────────────────
    // This is the key GPU fix: when the shadow and clip are on the same widget,
    // Flutter is forced to call saveLayer() to composite the shadow with the
    // clipped content. Separating them eliminates that cost entirely.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        // Material with Clip.antiAlias uses the GPU stencil buffer —
        // it is dramatically cheaper than ClipRRect's saveLayer path.
        color: AppConstants.colorCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Background image with Hero ────────────────────────────────
            // The Hero tag creates a seamless shared-element transition to
            // VisaDetailScreen. The tag 'visa-${visa.slug}' must match
            // the Hero wrapping the image in visa_detail_screen.dart.
            Positioned.fill(
              child: Hero(
                tag: 'visa-hero-${visa.slug}',
                child: CachedNetworkImage(
                  imageUrl: visa.image,
                  fit: BoxFit.cover,
                  // Limit decoded size in memory — prevents image cache bloat
                  memCacheWidth: 800,
                  memCacheHeight: 800,
                  placeholder: (context, url) =>
                      const ShimmerCard(height: double.infinity, radius: 0),
                  errorWidget: (context, url, error) => Container(
                    color: AppConstants.colorCard,
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: AppConstants.colorBodyText,
                    ),
                  ),
                ),
              ),
            ),

            // ── Dark gradient overlay ────────────────────────────────────
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x66000000),
                      Color(0xCC000000),
                    ],
                    stops: [0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // ── Top badge ───────────────────────────────────────────────
            PositionedDirectional(
              top: 16,
              start: 16,
              child: MonoTag(
                label: AppStrings.of(locale).verifiedRoute,
                color: AppConstants.colorAccent,
                icon: Icons.verified_rounded,
              ),
            ),

            // ── Bottom content ──────────────────────────────────────────
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: AppConstants.colorEmerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.of(locale).jurisdiction,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white60,
                            letterSpacing: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      visa.localizedTitle(locale),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isFeatured ? 22 : 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),

                    if (isFeatured) ...[
                      const SizedBox(height: 6),
                      Text(
                        visa.localizedDescShort(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white24, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          _MetaItem(
                            label: AppStrings.of(locale).clearance,
                            value: visa.localizedDuration(locale),
                          ),
                          if (visa.price != null) ...[
                            const SizedBox(width: 16),
                            _MetaItem(
                              label: AppStrings.of(locale).capitalReq,
                              value:
                                  '${visa.price!.toInt()} ${visa.currency}',
                              valueColor: AppConstants.colorEmerald,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetaItem({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white54,
            letterSpacing: 1.2,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
