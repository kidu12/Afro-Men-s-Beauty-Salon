import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_tag.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/hairstyle.dart';
import '../../data/models/service_item.dart';
import '../../data/services/local_storage_service.dart';
import '../services/service_providers.dart';
import '../booking/booking_state_provider.dart';
import 'style_providers.dart';

class StyleDetailScreen extends ConsumerStatefulWidget {
  final String styleId;

  const StyleDetailScreen({super.key, required this.styleId});

  @override
  ConsumerState<StyleDetailScreen> createState() => _StyleDetailScreenState();
}

class _StyleDetailScreenState extends ConsumerState<StyleDetailScreen> {
  int _selectedMediaIndex = 0;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final storage = await LocalStorageService.init();
    setState(() {
      _isFavorite = storage.isFavorite('style_${widget.styleId}');
    });
  }

  Future<void> _toggleFavorite() async {
    final storage = await LocalStorageService.init();
    await storage.toggleFavorite('style_${widget.styleId}');
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _initVideoIfSelected(Hairstyle style) {
    if (style.media.isEmpty) return;
    final currentMedia = style.media[_selectedMediaIndex];
    if (currentMedia.isVideo && _videoController == null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(currentMedia.mediaUrl))
        ..initialize().then((_) {
          if (mounted) {
            _videoController!.setVolume(_isMuted ? 0 : 1);
            _videoController!.setLooping(true);
            _videoController!.play();
            setState(() => _isPlaying = true);
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _bookThisStyle(Hairstyle style, ServiceItem? service) {
    ref.read(bookingStateProvider.notifier).preselectStyle(style, service);
    context.push(AppConstants.bookingPath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final styleAsync = ref.watch(hairstyleDetailProvider(widget.styleId));
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      body: styleAsync.when(
        data: (style) {
          if (style == null) {
            return Center(child: Text(l10n.styleDetails));
          }

          _initVideoIfSelected(style);

          // Find recommended service if linked
          ServiceItem? recommendedService;
          if (style.recommendedServiceId != null && servicesAsync.hasValue) {
            final list = servicesAsync.value!;
            recommendedService = list.firstWhere(
              (s) => s.id == style.recommendedServiceId,
              orElse: () => list.first,
            );
          }

          final currentMedia = style.media.isNotEmpty ? style.media[_selectedMediaIndex] : null;

          return CustomScrollView(
            slivers: [
              // Media Hero App Bar
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isFavorite ? AppColors.gold : Colors.white,
                        size: 20,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (currentMedia != null && currentMedia.isVideo && _videoController != null && _videoController!.value.isInitialized)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                                _isPlaying = false;
                              } else {
                                _videoController!.play();
                                _isPlaying = true;
                              }
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                              if (!_isPlaying)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: AppColors.gold, size: 40),
                                ),
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: IconButton(
                                  icon: Icon(
                                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isMuted = !_isMuted;
                                      _videoController!.setVolume(_isMuted ? 0 : 1);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Image.network(
                          currentMedia?.mediaUrl ?? style.primaryImageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceElevated),
                        ),
                      // Vignette overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.8),
                              AppColors.background,
                            ],
                            stops: const [0.6, 0.9, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.localizeCategory(style.category).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textInverse,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Style Title
                      Text(
                        style.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Media Switcher Thumbnails (if multiple media exists)
                      if (style.media.length > 1) ...[
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: style.media.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final m = style.media[index];
                              final isSelected = index == _selectedMediaIndex;
                              return InkWell(
                                onTap: () {
                                  _videoController?.pause();
                                  _videoController?.dispose();
                                  _videoController = null;
                                  setState(() {
                                    _selectedMediaIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.gold : AppColors.surfaceBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        m.thumbnailUrl ?? m.mediaUrl,
                                        fit: BoxFit.cover,
                                      ),
                                      if (m.isVideo)
                                        const Center(
                                          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Description
                      if (style.description != null) ...[
                        Text(
                          l10n.styleOverview,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          style.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Recommended Service Card
                      if (recommendedService != null) ...[
                        Text(
                          l10n.recommendedService,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GlassCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.content_cut_rounded, color: AppColors.gold, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.localizeServiceName(recommendedService.name),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (recommendedService.durationMinutes != null) ...[
                                          const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            Formatters.formatDuration(recommendedService.durationMinutes, l10n.isAmharic) ?? '',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        // PriceTag: rendered only for Home to Home service!
                                        if (recommendedService.shouldShowPrice)
                                          PriceTag(price: recommendedService.price, isBadge: true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Big Central CTA: BOOK THIS STYLE
                      PrimaryButton(
                        title: l10n.bookThisStyle,
                        icon: Icons.calendar_month_rounded,
                        onPressed: () => _bookThisStyle(style, recommendedService),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
