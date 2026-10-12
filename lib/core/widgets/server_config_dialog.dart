import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';

/// Shows an interactive Server Configuration Dialog allowing developers/testers
/// to switch between Wi-Fi IP, Emulator 10.0.2.2, and Localhost, test the connection
/// in real-time, and save it across app launches.
Future<bool?> showServerConfigDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const ServerConfigDialog(),
  );
}

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  bool? _testSuccess;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.baseUrl);
    // Auto-test current URL on opening
    _runTest(ApiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _runTest(String url) async {
    setState(() {
      _isTesting = true;
      _testSuccess = null;
      _testMessage = null;
    });

    final res = await ApiService.testConnection(url.trim());
    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _testSuccess = res['success'] == true;
      if (_testSuccess == true) {
        final data = res['details']?['data'];
        final dbStatus = data is Map ? data['database'] : 'ok';
        _testMessage = 'Server reachable! (Database: $dbStatus)';
      } else {
        _testMessage = res['message'] ?? 'Connection timed out or refused.';
      }
    });
  }

  Future<void> _saveAndApply() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    // Update in-memory API service
    ApiService.setBaseUrl(url);

    // Save to persistent storage
    final storage = await LocalStorageService.init();
    await storage.setSavedServerBaseUrl(url);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Server URL saved: $url',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceElevated : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dns_rounded, color: AppColors.gold, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'XAMPP PHP & MySQL Backend',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Server URL Input
            const Text(
              'Server Base URL',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'http://192.168.0.111/afro_barber_api/public',
                prefixIcon: const Icon(Icons.link_rounded, size: 18, color: AppColors.gold),
                suffixIcon: IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                  onPressed: () => _urlController.clear(),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
              onChanged: (_) {
                setState(() {
                  _testSuccess = null;
                  _testMessage = null;
                });
              },
            ),
            const SizedBox(height: 14),

            // Quick Preset Selection Chips
            const Text(
              'Quick Presets',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetChip(
                  label: '📱 Wi-Fi IP (192.168.0.111)',
                  url: ApiService.defaultLanUrl,
                ),
                _presetChip(
                  label: '💻 Emulator (10.0.2.2)',
                  url: ApiService.defaultEmulatorUrl,
                ),
                _presetChip(
                  label: '🌐 Localhost (127.0.0.1)',
                  url: ApiService.defaultLocalhostUrl,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Live Connection Status Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testSuccess == true
                    ? AppColors.success.withValues(alpha: 0.12)
                    : _testSuccess == false
                        ? AppColors.error.withValues(alpha: 0.12)
                        : isDark
                            ? AppColors.surface
                            : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _testSuccess == true
                      ? AppColors.success.withValues(alpha: 0.4)
                      : _testSuccess == false
                          ? AppColors.error.withValues(alpha: 0.4)
                          : AppColors.surfaceBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isTesting)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                      ),
                    )
                  else if (_testSuccess == true)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    )
                  else if (_testSuccess == false)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 18),
                    ),
                  Expanded(
                    child: Text(
                      _isTesting
                          ? 'Testing connection to server...'
                          : _testMessage ?? 'Tap "Test Connection" to verify endpoint availability.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _testSuccess == true
                            ? AppColors.success
                            : _testSuccess == false
                                ? AppColors.error
                                : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Dialog Actions
            Row(
              children: [
                // Test Connection Button
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : () => _runTest(_urlController.text),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Test', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveAndApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textInverse,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Save & Connect',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip({required String label, required String url}) {
    final isSelected = _urlController.text.trim() == url;
    return InkWell(
      onTap: () {
        _urlController.text = url;
        _runTest(url);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withValues(alpha: 0.2) : AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.surfaceBorder,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.gold : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
