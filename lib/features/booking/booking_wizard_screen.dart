import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/media_upload_helper.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/price_tag.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/widgets/time_slot_chip.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/time_slot.dart';
import '../services/service_providers.dart';
import '../barbers/barber_providers.dart';
import 'booking_state_provider.dart';

class BookingWizardScreen extends ConsumerStatefulWidget {
  const BookingWizardScreen({super.key});

  @override
  ConsumerState<BookingWizardScreen> createState() => _BookingWizardScreenState();
}

class _BookingWizardScreenState extends ConsumerState<BookingWizardScreen> {
  final _notesController = TextEditingController();
  final _txRefController = TextEditingController();
  List<TimeSlot> _timeSlots = [];
  bool _isLoadingSlots = false;
  XFile? _receiptImage;
  String? _receiptImageUrl;
  bool _isUploadingReceipt = false;

  Future<void> _pickReceiptScreenshot() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() {
        _receiptImage = picked;
        _isUploadingReceipt = true;
      });

      try {
        if (!kIsWeb) {
          final url = await MediaUploadHelper.uploadFile(
            file: File(picked.path),
            bucket: 'receipts',
            folder: 'prepayments',
            contentType: 'image/jpeg',
          );
          if (mounted) {
            setState(() {
              _receiptImageUrl = url;
              _isUploadingReceipt = false;
            });
          }
        } else {
          setState(() {
            _receiptImageUrl = picked.name;
            _isUploadingReceipt = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _receiptImageUrl = 'local://${picked.name}';
            _isUploadingReceipt = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingReceipt = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlotsIfReady();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _txRefController.dispose();
    super.dispose();
  }

  Future<void> _loadSlotsIfReady() async {
    final state = ref.read(bookingStateProvider);
    if (state.selectedService != null && (state.selectedBarber != null || state.isAnyBarber)) {
      setState(() => _isLoadingSlots = true);
      final barbers = ref.read(barbersProvider).value ?? [];
      var barberId = state.selectedBarber?.id;
      if (barberId == null || state.isAnyBarber) {
        if (barbers.isNotEmpty) {
          barberId = barbers.first.id;
        }
      }
      if (barberId != null || state.isAnyBarber) {
        try {
          final slots = await ref.read(bookingStateProvider.notifier).loadAvailableSlots(
                barberId ?? '',
                state.selectedService!.id,
                state.selectedDate,
                allBarbers: barbers,
                isAny: state.isAnyBarber,
              );
          if (mounted) {
            setState(() {
              _timeSlots = slots;
              _isLoadingSlots = false;
            });
          }
        } catch (e) {
          if (mounted) setState(() => _isLoadingSlots = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingSlots = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bookingState = ref.watch(bookingStateProvider);
    final notifier = ref.read(bookingStateProvider.notifier);

    // If confirmed, show success screen
    if (bookingState.confirmedAppointment != null) {
      return _buildSuccessScreen(bookingState.confirmedAppointment!, l10n);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingWizardTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        leading: bookingState.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => notifier.goToStep(bookingState.currentStep - 1),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Indicator
            _buildStepIndicator(bookingState.currentStep, l10n),
            const SizedBox(height: 12),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _buildCurrentStepView(bookingState, notifier, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep, AppLocalizations l10n) {
    final stepLabels = [
      l10n.stepService,
      l10n.stepBarber,
      l10n.appointmentDate,
      l10n.appointmentTime,
      l10n.stepConfirm,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              final isDone = index < currentStep;
              final isCurrent = index == currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: isDone || isCurrent ? AppColors.gold : AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentStep + 1}/5: ${stepLabels[currentStep].toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepView(BookingState state, BookingNotifier notifier, AppLocalizations l10n) {
    switch (state.currentStep) {
      case 0:
        return _buildStep1Service(state, notifier, l10n);
      case 1:
        return _buildStep2Barber(state, notifier, l10n);
      case 2:
        return _buildStep3Date(state, notifier, l10n);
      case 3:
        return _buildStep4Time(state, notifier, l10n);
      case 4:
      default:
        return _buildStep5Confirm(state, notifier, l10n);
    }
  }

  // STEP 1: SELECT SERVICE
  Widget _buildStep1Service(BookingState state, BookingNotifier notifier, AppLocalizations l10n) {
    final servicesAsync = ref.watch(servicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.selectedHairstyle != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l10n.styleLabel}: ${state.selectedHairstyle!.name}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(l10n.selectServiceTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        servicesAsync.when(
          data: (services) => Column(
            children: services.map((service) {
              final isSelected = state.selectedService?.id == service.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  borderColor: isSelected ? AppColors.gold : null,
                  onTap: () {
                    notifier.selectService(service);
                    final isHome = service.name.toLowerCase().contains('home to home');
                    if (isHome) {
                      final barbers = ref.read(barbersProvider).value ?? [];
                      final tedi = barbers.where((b) => b.name.toLowerCase().contains('ted')).firstOrNull;
                      if (tedi != null) {
                        notifier.selectBarber(tedi);
                      }
                    }
                    notifier.goToStep(1);
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          service.imageUrl ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.surfaceElevated,
                            child: const Icon(Icons.content_cut, color: AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.localizeServiceName(service.name),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.localizeServiceDesc(service.description),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (service.durationMinutes != null) ...[
                                  const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    Formatters.formatDuration(service.durationMinutes, l10n.isAmharic) ?? '',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (service.isHomeToHome && service.hasPrice)
                                  PriceTag(price: service.price, isBadge: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                        size: isSelected ? 22 : 14,
                        color: isSelected ? AppColors.gold : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (_, _) => const Text('Could not load services'),
        ),
      ],
    );
  }

  Widget _buildStep2Barber(BookingState state, BookingNotifier notifier, AppLocalizations l10n) {
    final barbersAsync = ref.watch(barbersProvider);
    final isHome = state.selectedService?.name.toLowerCase().contains('home to home') ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectBarberTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        if (isHome)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.home_work_rounded, color: AppColors.gold, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Home to Home service is exclusively provided by our dedicated specialist, Tedi.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          )
        else
          // Any Available Barber Option
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: state.isAnyBarber ? AppColors.gold : null,
              onTap: () {
                notifier.selectBarber(null, isAny: true);
                notifier.goToStep(2);
                _loadSlotsIfReady();
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shuffle_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.anyBarber,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'First available master barber',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    state.isAnyBarber ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                    size: state.isAnyBarber ? 22 : 14,
                    color: state.isAnyBarber ? AppColors.gold : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

        barbersAsync.when(
          data: (barbers) {
            final filteredBarbers = isHome
                ? barbers.where((b) => b.name.toLowerCase().contains('ted')).toList()
                : barbers;
            return Column(
              children: filteredBarbers.map((barber) {
              final isSelected = !state.isAnyBarber && state.selectedBarber?.id == barber.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  borderColor: isSelected ? AppColors.gold : null,
                  onTap: () {
                    notifier.selectBarber(barber);
                    notifier.goToStep(2);
                    _loadSlotsIfReady();
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: barber.avatarUrl != null ? NetworkImage(barber.avatarUrl!) : null,
                        backgroundColor: AppColors.surfaceElevated,
                        child: barber.avatarUrl == null ? const Icon(Icons.person, color: AppColors.gold) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              barber.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              barber.bio != null && barber.bio!.isNotEmpty
                                  ? barber.bio!
                                  : 'Master Barber',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            RatingBadge(
                              rating: barber.ratingAvg,
                              totalReviews: barber.totalReviews,
                              experienceYears: barber.experienceYears,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                        size: isSelected ? 22 : 14,
                        color: isSelected ? AppColors.gold : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (_, _) => const Text('Could not load barbers'),
        ),
      ],
    );
  }

  // STEP 3: SELECT DATE
  Widget _buildStep3Date(BookingState state, BookingNotifier notifier, AppLocalizations l10n) {
    final today = DateTime.now();
    final dates = List.generate(14, (i) => today.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectDateTimeTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),

        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = DateUtils.isSameDay(state.selectedDate, date);

              return InkWell(
                onTap: () {
                  notifier.selectDate(date);
                  _loadSlotsIfReady();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 65,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.gold : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          title: l10n.continueBtn,
          onPressed: () {
            notifier.goToStep(3);
            _loadSlotsIfReady();
          },
        ),
      ],
    );
  }

  // STEP 4: SELECT TIME
  Widget _buildStep4Time(BookingState state, BookingNotifier notifier, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.selectTime}: ${Formatters.formatShortDate(state.selectedDate, l10n.isAmharic)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '${l10n.duration}: ${Formatters.formatDuration(state.selectedService?.durationMinutes, l10n.isAmharic) ?? (l10n.isAmharic ? "45 ደቂቃ" : "45 min")}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        if (_isLoadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          )
        else if (_timeSlots.isEmpty)
          Text(l10n.noSlotsAvailable)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isSelected = state.selectedTimeSlot?.timeString == slot.timeString;
              return TimeSlotChip(
                timeLabel: slot.displayLabel,
                isSelected: isSelected,
                isAvailable: slot.isAvailable,
                onTap: () => notifier.selectTimeSlot(slot),
              );
            },
          ),

        const SizedBox(height: 28),
        if (state.selectedTimeSlot != null)
          PrimaryButton(
            title: l10n.stepConfirm.toUpperCase(),
            onPressed: () => notifier.goToStep(4),
          ),
      ],
    );
  }

  // STEP 5: CONFIRMATION
  Widget _buildStep5Confirm(BookingState state, BookingNotifier notifier, AppLocalizations l10n) {
    final isHome = state.selectedService?.isHomeToHome ?? false;
    const double prePaymentAmount = 1000.0;
    final double totalPrice = state.selectedService?.price?.toDouble() ?? 5000.0;
    final double balanceDue = totalPrice - prePaymentAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.confirmAppointment, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(l10n.reviewBookingTitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        GlassCard(
          child: Column(
            children: [
              _summaryRow(l10n.selectedService, l10n.localizeServiceName(state.selectedService?.name ?? 'Haircut')),
              if (state.selectedHairstyle != null) ...[
                const Divider(),
                _summaryRow(l10n.styleLabel, state.selectedHairstyle!.name),
              ],
              const Divider(),
              _summaryRow(l10n.selectedBarber, state.isAnyBarber ? l10n.anyBarber : (state.selectedBarber?.name ?? 'Master Barber')),
              const Divider(),
              _summaryRow(l10n.appointmentDate, Formatters.formatDate(state.selectedDate, l10n.isAmharic)),
              const Divider(),
              _summaryRow(l10n.appointmentTime, state.selectedTimeSlot?.displayLabel ?? '09:00 AM'),
              const Divider(),
              _summaryRow(l10n.duration, Formatters.formatDuration(state.selectedService?.durationMinutes, l10n.isAmharic) ?? (l10n.isAmharic ? '45 ደቂቃ' : '45 min')),

              if (state.selectedService?.shouldShowPrice == true) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.totalPrice, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    PriceTag(price: state.selectedService?.price),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.prePaymentNow, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    Text(
                      '${prePaymentAmount.toStringAsFixed(0)} ${l10n.currency}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gold),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.balanceAfterService, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '${balanceDue.toStringAsFixed(0)} ${l10n.currency}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (isHome) ...[
          // Pre-payment info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                      children: [
                        TextSpan(text: l10n.prePaymentNotice1),
                        TextSpan(
                          text: '1,000 ${l10n.currency}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold),
                        ),
                        TextSpan(text: l10n.prePaymentNotice2),
                        TextSpan(
                          text: '4,000 ${l10n.currency}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: l10n.prePaymentNotice3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Payment Screenshot Uploader ──
          if (_receiptImage == null) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickReceiptScreenshot,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppColors.gold,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.uploadPaymentScreenshot,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.uploadPaymentScreenshotSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success, width: 1.5),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(
                            _receiptImage!.path,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: AppColors.surfaceHighlight,
                              child: const Icon(Icons.receipt_long, color: AppColors.gold),
                            ),
                          )
                        : Image.file(
                            File(_receiptImage!.path),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: AppColors.surfaceHighlight,
                              child: const Icon(Icons.receipt_long, color: AppColors.gold),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                l10n.screenshotUploaded,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _receiptImage!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickReceiptScreenshot,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.gold),
                    label: Text(l10n.changeScreenshot, style: const TextStyle(fontSize: 11, color: AppColors.gold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _receiptImage = null;
                        _receiptImageUrl = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Optional Transaction Number
          Row(
            children: [
              const Icon(Icons.tag_rounded, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.optionalTxRef,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _txRefController,
            decoration: InputDecoration(
              hintText: l10n.optionalTxRefHint,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Optional Notes
        Text(l10n.specialNotes, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          onChanged: (val) => notifier.setNotes(val),
          decoration: InputDecoration(
            hintText: l10n.specialNotesHint,
          ),
        ),
        const SizedBox(height: 24),

        if (state.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
        ],

        PrimaryButton(
          title: l10n.confirmAndBookBtn,
          isLoading: state.isLoading || _isUploadingReceipt,
          onPressed: () async {
            if (isHome && _receiptImage == null && (_receiptImageUrl == null || _receiptImageUrl!.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.screenshotRequired),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final barbers = ref.read(barbersProvider).value ?? [];
            final defaultBarberId = barbers.isNotEmpty ? barbers.first.id : null;

            if (isHome) {
              final existingNotes = _notesController.text.trim();
              final txRef = _txRefController.text.trim();
              final receiptRef = _receiptImageUrl ?? _receiptImage?.name ?? 'screenshot_attached';
              final parts = <String>[
                if (existingNotes.isNotEmpty) existingNotes,
                'Pre-payment: ${prePaymentAmount.toStringAsFixed(0)} ETB (Balance: ${balanceDue.toStringAsFixed(0)} ETB)',
                'Receipt: $receiptRef',
                if (txRef.isNotEmpty) 'TX: $txRef',
              ];
              notifier.setNotes(parts.join(' | '));
            }

            await notifier.confirmAppointment(defaultBarberId: defaultBarberId);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(dynamic apt, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.gold, size: 54),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.bookingSuccessTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    apt.appointmentReference,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.bookingSuccessMsg}\n${Formatters.formatShortDate(apt.appointmentDate, l10n.isAmharic)} • ${apt.startTime.substring(0, 5)} (${apt.barberName})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  title: l10n.viewAppointmentsBtn,
                  onPressed: () {
                    ref.read(bookingStateProvider.notifier).reset();
                    context.go(AppConstants.appointmentsPath);
                  },
                ),
                const SizedBox(height: 14),
                SecondaryButton(
                  title: l10n.navHome.toUpperCase(),
                  onPressed: () {
                    ref.read(bookingStateProvider.notifier).reset();
                    context.go(AppConstants.homePath);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
