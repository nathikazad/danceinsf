import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_app/screens/stripe_dialog.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learning_app/utils/user_payments.dart';
import 'package:learning_app/widgets/landing_page_widgets/features_widget.dart';
import 'package:learning_app/widgets/landing_page_widgets/landing_appbar.dart';
import 'package:learning_app/widgets/landing_page_widgets/landing_footer.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 750;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: LandingAppBar(isDesktop: isDesktop),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 48 : 24,
                horizontal: isDesktop ? 64 : 16,
              ),
              child: _VideoPreview(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 48 : 32,
                horizontal: isDesktop ? 64 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.whyChooseCourse,
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 12),
                  // Text(
                  //   'Experience the most comprehensive online bachata program designed to transform you into a confident, passionate dancer.',
                  //   style: TextStyle(
                  //     fontSize: isDesktop ? 18 : 14,
                  //     color: Colors.black87,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 32),
                  FeaturesGrid(isDesktop: isDesktop),
                  const SizedBox(height: 32),
                  // Conditionally show buy or course access widgets
                  Consumer(
                    builder: (context, ref, child) {
                      final hasPayment = ref.watch(userHasPaymentProvider);
                      
                      return hasPayment.when(
                        data: (hasPayment) => hasPayment 
                          ? _CourseAccessWidget(isDesktop: isDesktop)
                          : _BuyButtonWidget(isDesktop: isDesktop, l10n: l10n),
                        loading: () => _LoadingWidget(isDesktop: isDesktop),
                        error: (error, stack) => _BuyButtonWidget(isDesktop: isDesktop, l10n: l10n),
                      );
                    },
                  ),
                ],
              ),
            ),
            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}


class _VideoPreview extends StatelessWidget {
  const _VideoPreview();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill, size: 64, color: Colors.black38),
              const SizedBox(height: 8),
              Text('${l10n.watchFreePreview}\n${l10n.introLesson}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyButtonWidget extends ConsumerWidget {
  final bool isDesktop;
  final AppLocalizations l10n;

  const _BuyButtonWidget({
    required this.isDesktop,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => StripePaymentDialog(
                onPaymentStatusRefresh: (ref) async {
                  ref.invalidate(userHasPaymentProvider);
                  await ref.read(userHasPaymentProvider.future);
                },
                publishableKey: 'pk_test_51RgHPYQ3gDIZndwWrWx1aNclnFjsh6E3v01vBdNZAfqMEw1ZEAshkauhbtObKB7F3U9OVp7RNpgMhJy7uT2NcV6U00KQIWykjt',
                stripeAccountId: 'acct_1Ro1fcQ3gDiXwojs',
                amount: 99900,
                currency: 'mxn',
                itemTitle: l10n.bachataCoursePrice(999),
                itemDescription: l10n.courseDescription,
                metadata: {
                  'course_name': 'Bachata Course',
                  'course_id': 1,
                  'payment_type': 'course',
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 32,
              vertical: isDesktop ? 16 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            l10n.buyForPrice(999),
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.refundPolicy,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CourseAccessWidget extends StatelessWidget {
  final bool isDesktop;

  const _CourseAccessWidget({
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to appropriate video app based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 600; // Using 600px threshold as in main.dart
        
        if (isDesktop) {
          context.go('/desktop-video');
        } else {
          context.go('/mobile-video');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48 : 32,
          vertical: isDesktop ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Go to Course',
        style: TextStyle(
          fontSize: isDesktop ? 20 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  final bool isDesktop;

  const _LoadingWidget({
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[400],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48 : 32,
          vertical: isDesktop ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Loading...'),
    );
  }
}
