import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:learning_app/screens/stripe_dialog.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:learning_app/screens/login_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        child: _LandingAppBar(isDesktop: isDesktop),
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
                  _FeaturesGrid(isDesktop: isDesktop),
                  const SizedBox(height: 32),
                  // Add centered Buy Button
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const StripePaymentDialog(),
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
                      l10n.buyForPrice,
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
                  )
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _LandingAppBar extends ConsumerWidget {
  final bool isDesktop;
  const _LandingAppBar({required this.isDesktop});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).state.user;
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: 
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child:
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'My Bachata',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    TextSpan(
                      text: ' Moves',
                      style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Language selector
              // PopupMenuButton<String>(
              //   onSelected: (String value) {
              //     if (value == 'en') {
              //       ref.read(localeProvider.notifier).state = const Locale('en');
              //     } else if (value == 'es') {
              //       ref.read(localeProvider.notifier).state = const Locale('es');
              //     }
              //   },
              //   itemBuilder: (BuildContext context) => [
              //     PopupMenuItem<String>(
              //       value: 'en',
              //       child: Row(
              //         children: [
              //           const Text('🇺🇸 '),
              //           const SizedBox(width: 8),
              //           const Text('English'),
              //         ],
              //       ),
              //     ),
              //     PopupMenuItem<String>(
              //       value: 'es',
              //       child: Row(
              //         children: [
              //           const Text('🇪🇸 '),
              //           const SizedBox(width: 8),
              //           const Text('Español'),
              //         ],
              //       ),
              //     ),
              //   ],
              //   child: const Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 8.0),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(Icons.language, color: Colors.black),
              //         SizedBox(width: 4),
              //         Icon(Icons.arrow_drop_down, color: Colors.black),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 8),
              if (user == null)
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LoginDialog(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: Text(l10n.login),
                )
              else
                OutlinedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: Text(l10n.logout),
                ),
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

class _FeaturesGrid extends StatelessWidget {
  final bool isDesktop;
  const _FeaturesGrid({required this.isDesktop});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      _FeatureCard(
        icon: Icons.music_note,
        title: l10n.onlyForSocials,
        description: l10n.onlyForSocialsDescription,
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.groups,
        title: l10n.bodyLanguage,
        description: l10n.bodyLanguageDescription,
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.music_note,
        title: l10n.noPrizesOnlyFun,
        description: l10n.noPrizesOnlyFunDescription,
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.access_time,
        title: l10n.noBasics,
        description: l10n.noBasicsDescription,
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.emoji_events,
        title: l10n.unlimitedReplays,
        description: l10n.unlimitedReplaysDescription,
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.favorite,
        title: l10n.easyReview,
        description: l10n.easyReviewDescription,
        isDesktop: isDesktop,
      ),
    ];
    
    return ResponsiveGridRow(
      children: features.map((feature) => ResponsiveGridCol(
        xs: 12, // 1 column on mobile
        md: 6,  // 2 columns on tablet
        lg: 4,  // 3 columns on desktop
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: feature,
        ),
      )).toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDesktop;
  const _FeatureCard({required this.icon, required this.title, required this.description, required this.isDesktop});
  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return SizedBox(
        height: 320,
        child: _card(context),
      );
    } else {
      return _card(context);
    }
  }

  Widget _card(BuildContext context) {
      return Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Center(
              //   child: Container(
              //     width: 60,
              //     height: 60,
              //     decoration: BoxDecoration(
              //       color: Colors.orange[700],
              //       shape: BoxShape.circle,
              //     ),
              //     child: Icon(icon, color: Colors.white, size: 32),
              //   ),
              // ),
              // const SizedBox(height: 20),
              AutoSizeText(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    // );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Text(
            l10n.appTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.footerTagline,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.facebook, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.mail, color: Colors.orange),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.copyright,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.madeWithLove,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
} 
