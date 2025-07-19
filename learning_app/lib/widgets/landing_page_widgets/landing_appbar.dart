import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:learning_app/screens/login_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandingAppBar extends ConsumerWidget {
  final bool isDesktop;
  const LandingAppBar({required this.isDesktop});
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
