import 'package:dance_sf/utils/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dance_shared/dance_shared.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                alignment: Alignment.center,
                //padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  l10n.drawerMenu,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),
              ),
              // Language Selector
              ListTile(
                leading: Icon(
                  Icons.language,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.settingsLanguage,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                trailing: DropdownButton<Locale>(
                  value: currentLocale,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(
                        l10n.settingsLanguageEnglish,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    DropdownMenuItem(
                      value: const Locale('es'),
                      child: Text(
                        l10n.settingsLanguageSpanish,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      ref.read(localeProvider.notifier).setLocale(newLocale);
                    }
                  },
                ),
              ),
              const SizedBox(height: 25),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.drawerHelp,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/help');
                },
              ),
              const SizedBox(height: 25),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.email_outlined,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.drawerContact,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                onTap: () {
                  // send email to nathikazad@gmail.com
                  final email = 'nathikazad@gmail.com';
                  final subject = 'Contact';
                  final body = 'Hello, I have a question about the event.';
                  final url = 'mailto:$email?subject=$subject&body=$body';
                  launchUrl(Uri.parse(url));
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 25),
              const Divider(),
              if (ref.watch(authProvider).user?.id == 'b0ffdf47-a4e3-43e9-b85e-15c8af0a1bd6')
                ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings,
                    size: 25,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.drawerAdmin),
                  onTap: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).push('/activity');
                  },
                ),
              if (ref.watch(authProvider).user?.id == 'b0ffdf47-a4e3-43e9-b85e-15c8af0a1bd6')
                const SizedBox(height: 25),
              if (ref.watch(authProvider).user?.id == 'b0ffdf47-a4e3-43e9-b85e-15c8af0a1bd6')
                const Divider(),
              if (ref.watch(authProvider).user != null)
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    size: 25,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.drawerRevokeOTP),
                  onTap: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                ),
              if (ref.watch(authProvider).user == null)
                ListTile(
                  leading: Icon(
                    Icons.login,
                    size: 25,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n.drawerLogin),
                  onTap: () async {
                    await GoRouter.of(context).push('/verify');
                    if (!context.mounted) return;
                    context.pop(true);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
