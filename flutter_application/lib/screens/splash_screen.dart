import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Illustration placeholder
              SizedBox(
                height: 260,
                child: Image.asset(
                  'assets/images/sf_dance.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.headlineMedium,
                  children: [
                    const TextSpan(text: 'Dance in '),
                    TextSpan(
                      text: 'SF',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                "Don't Think, Just Dance",
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).push('/events');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Find Local Events In San Francisco',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
