import 'package:dance_shared/auth/auth_service.dart';
import 'package:dance_shared/login_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_shared/stripe/stripe_dialog.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learning_app/utils/user_payments.dart';
import 'package:learning_app/utils/browser_detection.dart';
import 'package:learning_app/widgets/landing_page_widgets/features_widget.dart';
import 'package:learning_app/widgets/landing_page_widgets/landing_appbar.dart';
import 'package:learning_app/widgets/landing_page_widgets/landing_footer.dart';
import 'package:learning_app/widgets/safari_video_player.dart';
import 'package:learning_app/widgets/chewie_video_player.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: LandingAppBar(isDesktop: isDesktop),
      ),
      endDrawer: isDesktop ? null : MobileDrawer(l10n: l10n),
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


class _VideoPreview extends StatefulWidget {
  const _VideoPreview();

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  bool _isPlaying = false;
  final String _videoUrl = 'https://stream.mux.com/KU3YwYdm015GdVuFIwgz00VV3tS01EVUOzOymBlVdAOh02U.m3u8';

  void _onPlayButtonPressed() {
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isPlaying
                ? _buildVideoPlayer()
                : GestureDetector(
                    onTap: _onPlayButtonPressed,
                    child: Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: Colors.black38,
                            ),
                            // const SizedBox(height: 8),
                            // Text(
                            //   '${l10n.watchFreePreview}\n${l10n.introLesson}',
                            //   textAlign: TextAlign.center,
                            //   style: const TextStyle(fontSize: 16, color: Colors.black54),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Use Safari video player for Safari on Mac, Chewie for everything else
    if (BrowserDetection.isSafariOnMac()) {
      return SafariVideoPlayer(
        videoUrl: _videoUrl,
        aspectRatio: 16 / 9,
        maxHeight: 400,
      );
    } else {
      return ChewieVideoPlayer(
        videoUrl: _videoUrl,
        aspectRatio: 16 / 9,
        maxHeight: 400,
      );
    }
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
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => LoginDialog(l10n: l10n, notify: false),
            );
            if (ref.read(authProvider).user == null) {
              if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.loginRequired),
                  ),
                );
              }
              return;
            }
            if (context.mounted) {
              await showDialog(
                context: context,
                builder: (context) => StripePaymentDialog(
                  postPaymentCallback: (ref) async {
                    ref.invalidate(userHasPaymentProvider);
                    await ref.read(userHasPaymentProvider.future);
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isDesktop = screenWidth > 600; // Using 600px threshold as in landing page
                    if (isDesktop) {
                      if (context.mounted) {
                        context.go('/desktop-video');
                      }
                    } else {
                      if (context.mounted)  {
                        context.go('/mobile-video');
                      }
                    }
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
                  l10n: l10n,
                ),
              );
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
            l10n.buyForPrice(999, 'MXN'),
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