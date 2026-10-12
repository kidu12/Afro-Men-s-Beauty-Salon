import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';

class AdminHoursScreen extends StatefulWidget {
  const AdminHoursScreen({super.key});

  @override
  State<AdminHoursScreen> createState() => _AdminHoursScreenState();
}

class _AdminHoursScreenState extends State<AdminHoursScreen> {
  final List<Map<String, dynamic>> _days = [
    {'day': 'Monday', 'open': '09:00 AM', 'close': '08:00 PM', 'closed': false},
    {'day': 'Tuesday', 'open': '09:00 AM', 'close': '08:00 PM', 'closed': false},
    {'day': 'Wednesday', 'open': '09:00 AM', 'close': '08:00 PM', 'closed': false},
    {'day': 'Thursday', 'open': '09:00 AM', 'close': '08:00 PM', 'closed': false},
    {'day': 'Friday', 'open': '09:00 AM', 'close': '08:00 PM', 'closed': false},
    {'day': 'Saturday', 'open': '09:00 AM', 'close': '08:00 PM', 'closed': false},
    {'day': 'Sunday', 'open': '10:00 AM', 'close': '06:00 PM', 'closed': false},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.businessHours, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Weekly Operating Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Ayat 49 Condominium branch opening times for booking calculations.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),

          ...List.generate(_days.length, (index) {
            final d = _days[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d['day'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Text('${d['open']} – ${d['close']}', style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Switch(
                          value: !d['closed'],
                          activeThumbColor: AppColors.gold,
                          onChanged: (val) {
                            setState(() => _days[index]['closed'] = !val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          PrimaryButton(
            title: l10n.saveOperatingHours,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Operating hours updated successfully! 💈')),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
