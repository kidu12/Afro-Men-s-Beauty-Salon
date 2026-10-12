import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';

class ShopInfoScreen extends StatelessWidget {
  const ShopInfoScreen({super.key});

  static const String _mapsUrl = 'https://maps.app.goo.gl/PDfzMFJNBbj217NK9';

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(_mapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotOpenMaps)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.barbershopLocation, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch Photo & Info
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Afro Mens Beauty Salon',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            // Map preview tile
            GestureDetector(
              onTap: () => _openMaps(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap?center=9.0170412,38.8947858&zoom=16&size=600x200&markers=color:orange%7C9.0170412,38.8947858&key=AIzaSyBoYjeRtfVI0Jd8Q_9mnflo9i4sOYpShB0',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined, size: 40, color: AppColors.gold),
                          const SizedBox(height: 8),
                          Text(l10n.tapToOpenMaps, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Address row
            GestureDetector(
              onTap: () => _openMaps(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.shopCityCountry}\n(9.0170412, 38.8947858)',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded, color: AppColors.gold, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hours Card
            Text(l10n.operatingHours, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                children: [
                  _hourRow(l10n.monFriHours, '09:00 AM – 08:00 PM'),
                  const Divider(),
                  _hourRow(l10n.saturdayHours, '09:00 AM – 08:00 PM'),
                  const Divider(),
                  _hourRow(l10n.sundayHours, '10:00 AM – 06:00 PM'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Info
            Text(l10n.directContact, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                children: [
                  _contactRow(Icons.phone_outlined, '+251 911 223 344'),
                  const Divider(),
                  _contactRow(Icons.email_outlined, 'contact@afrobarber.com'),
                  const Divider(),
                  _contactRow(Icons.camera_alt_outlined, '@afrobarber_official'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              title: l10n.getDirections,
              icon: Icons.directions_rounded,
              onPressed: () => _openMaps(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _hourRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(time, style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
