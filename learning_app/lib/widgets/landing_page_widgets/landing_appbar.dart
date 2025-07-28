import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:dance_shared/login_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:learning_app/main.dart';

class LandingAppBar extends ConsumerWidget {
  final bool isDesktop;
  const LandingAppBar({required this.isDesktop});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: null,
      actions: isDesktop ? null : [
        IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: const Icon(Icons.menu, color: Colors.black),
        ),
      ],
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
              // Show buttons directly on desktop (width > mobileWidthpx)
              if (isDesktop) ...[
                // Language selector
                Consumer(
                  builder: (context, ref, child) {
                    final currentLocale = ref.watch(localeProvider);
                    final isEnglish = currentLocale.languageCode == 'en';
                    
                    return TextButton(
                      onPressed: () {
                        final newLocale = isEnglish ? const Locale('es') : const Locale('en');
                        ref.read(localeProvider.notifier).state = newLocale;
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isEnglish ? '🇪🇸' : '🇺🇸'),
                          const SizedBox(width: 4),
                          Text(isEnglish ? 'Español' : 'English'),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                if (user == null)
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => LoginDialog(l10n: l10n),
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
            ],
          ),
        ),
    );
  }
}


class MobileDrawer extends ConsumerWidget {
  final AppLocalizations l10n;

  const MobileDrawer({
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    
    return Drawer(
      child: Container(
        color: const Color(0xFFF8F6F2),
        child: Column(
          children: [
            const SizedBox(height: 60), // Space for app bar
            // Language selector
            Consumer(
              builder: (context, ref, child) {
                final currentLocale = ref.watch(localeProvider);
                final isEnglish = currentLocale.languageCode == 'en';
                
                return ListTile(
                  leading: Text(isEnglish ? '🇲🇽' : '🇺🇸', style: const TextStyle(fontSize: 20)),
                  title: Text(isEnglish ? 'Español' : 'English'),
                  onTap: () {
                    final newLocale = isEnglish ? const Locale('es') : const Locale('en');
                    ref.read(localeProvider.notifier).state = newLocale;
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const Divider(),
            // Login/Logout button
            ListTile(
              leading: Icon(user == null ? Icons.login : Icons.logout),
              title: Text(user == null ? l10n.login : l10n.logout),
              onTap: () {
                Navigator.pop(context);
                if (user == null) {
                  showDialog(
                    context: context,
                    builder: (context) => LoginDialog(l10n: l10n),
                  );
                } else {
                  ref.read(authProvider.notifier).signOut();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
