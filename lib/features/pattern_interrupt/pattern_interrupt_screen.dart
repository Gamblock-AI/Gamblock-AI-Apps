import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class PatternInterruptScreen extends StatefulWidget {
  const PatternInterruptScreen({super.key});
  @override
  State<PatternInterruptScreen> createState() => _PatternInterruptScreenState();
}

class _PatternInterruptScreenState extends State<PatternInterruptScreen> {
  bool _showRedirect = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showRedirect = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Center(
        child: _showRedirect
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.sage, size: 80),
                  const SizedBox(height: 24),
                  Text('Dorongan berhasil diputus', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => launchUrl(Uri.parse('https://gamblock-ai.vercel.app/education')),
                    child: const Text('Lanjut ke Psikoedukasi'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pan_tool, color: AppColors.amber, size: 100),
                  const SizedBox(height: 24),
                  const Text('BERHENTI', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Tarik napas dalam...', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 32),
                  const SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: AppColors.amber, strokeWidth: 3)),
                ],
              ),
      ),
    );
  }
}
