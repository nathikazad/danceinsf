import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class FeaturesGrid extends StatelessWidget {
  final bool isDesktop;
  const FeaturesGrid({required this.isDesktop});
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