import 'package:flutter/material.dart';
import 'package:dance_sf/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: Text('Menu',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary)),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100)),
                  child: Icon(
                    Icons.help_outline,
                    size: 25,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Contact',
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
              SizedBox(
                height: 25,
                child: Divider(),
              ),
              // ListTile(
              //   leading: Container(
              //       padding: const EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //           color: Theme.of(context)
              //               .colorScheme
              //               .primary
              //               .withOpacity(0.1),
              //           borderRadius: BorderRadius.circular(100)),
              //       child: Icon(
              //         Icons.chat,
              //         size: 25,
              //         color: Theme.of(context).colorScheme.primary,
              //       )),
              //   title: Text(
              //     'Groupchat',
              //     style: Theme.of(context).textTheme.labelLarge,
              //   ),
              //   onTap: () {
              //     // TODO: Implement Groupchat navigation
              //     Navigator.of(context).pop();
              //   },
              // ),
              // SizedBox(
              //   height: 25,
              //   child: Divider(),
              // ),
              // ListTile(
              //   leading: Container(
              //       padding: const EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //           color: Theme.of(context)
              //               .colorScheme
              //               .primary
              //               .withOpacity(0.1),
              //           borderRadius: BorderRadius.circular(100)),
              //       child: Icon(
              //         Icons.edit,
              //         size: 25,
              //         color: Theme.of(context).colorScheme.primary,
              //       )),
              //   title: Text(
              //     'Edits',
              //     style: Theme.of(context).textTheme.labelLarge,
              //   ),
              //   onTap: () {
              //     // TODO: Implement Edits navigation
              //     Navigator.of(context).pop();
              //   },
              // ),
              // SizedBox(
              //   height: 25,
              //   child: Divider(),
              // ),
              if (ref.watch(authProvider).state.user != null)
                ListTile(
                  leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100)),
                      child: Icon(
                        Icons.logout,
                        size: 25,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  title: const Text('Revoke OTP'),
                  onTap: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
