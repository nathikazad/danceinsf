import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:responsive_grid/responsive_grid.dart';
// import 'package:go_router/go_router.dart';
import 'package:dance_shared/auth/auth_service.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 750;
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
                    'Why Choose Our Bachata Course?',
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
                    onPressed: () {},
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
                      'Buy for \$49',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "If you are not satisfied with the course, you can cancel within 48 hours and get a full refund. No questions asked.",
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
                  child: const Text('Login'),
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
                  child: const Text('Logout'),
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
            children: const [
              Icon(Icons.play_circle_fill, size: 64, color: Colors.black38),
              SizedBox(height: 8),
              Text('Watch Free Preview\n3 minute intro lesson',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
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
    final features = [
      _FeatureCard(
        icon: Icons.music_note,
        title: 'Only For Socials',
        description: 'All our content is focused on social dancing not choreographies. That means you will be taught all the subtle details so you can perform these moves with anybody.',
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.groups,
        title: 'Body Language',
        description: 'Dancing Bachata is a conversation between two bodies. We focus on body language and teach you how to communicate with your partner, how to send signals and how to respond to them.',
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.music_note,
        title: 'No Prizes, Only Fun',
        description: 'This is not for people who want to win dance competitions, this is for people who just want to dance and enjoy the moment. We will make it easy for you to have fun.',
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.access_time,
        title: 'No Basic Steps',
        description: "This course is for intermediate and advanced dancers. We teach you new moves that you can use to express yourself and connect with your partner even better.",
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.emoji_events,
        title: 'Unlimited Replays',
        description: 'In workshops it is hard to remember everything you learned, but with pre-recorded videos you can watch them over and over again till it becomes second nature.',
        isDesktop: isDesktop,
      ),
      _FeatureCard(
        icon: Icons.favorite,
        title: 'Easy Review',
        description: "We have a dedicated section for reviewing the moves you have learned. So when your memory gets fuzzy, you can quickly refresh it. ",
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
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'My Bachata Moves',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn new bachata sensual moves from the comfort of your home.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
          const Text(
            '© 2024 Only For Bachateros. All rights reserved.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'Made with ♥ for bachata lovers worldwide',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
} 

// LoginDialog widget as a modal
class LoginDialog extends ConsumerStatefulWidget {
  const LoginDialog({super.key});

  @override
  ConsumerState<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isLoading = auth.state.isLoading;
    final error = auth.state.error;
    final user = auth.state.user;

    if (user != null) {
      // If already logged in, close the dialog
      Future.microtask(() => Navigator.of(context).pop());
    }

    // final theme = Theme.of(context);
    final orange = Colors.orange[700]!;
    final brown = const Color(0xFF6D4C41);
    final white = Colors.white;

    return Dialog(
      backgroundColor: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: brown),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to My Bachata Moves',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(error, style: TextStyle(color: orange)),
                ),
              if (!_otpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+1 555 123 4567',
                    labelStyle: TextStyle(color: brown),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: brown.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await authNotifier.signInWithPhone(_phoneController.text.trim());
                            setState(() {
                              _otpSent = true;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.apple, color: brown),
                    label: const Text('Sign in with Apple'),
                    onPressed: isLoading
                        ? null
                        : () async {
                            await authNotifier.signInWithApple(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      foregroundColor: brown,
                      side: BorderSide(color: brown.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.g_mobiledata, color: orange),
                    label: const Text('Sign in with Google'),
                    onPressed: isLoading
                        ? null
                        : () async {
                            await authNotifier.signInWithGoogle(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      foregroundColor: orange,
                      side: BorderSide(color: orange.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    labelStyle: TextStyle(color: brown),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: brown.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await authNotifier.verifyOTP(_phoneController.text.trim(), _otpController.text.trim());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Verify OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _otpSent = false;
                            _otpController.clear();
                          });
                        },
                  child: Text('Back to phone input', style: TextStyle(color: brown)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 