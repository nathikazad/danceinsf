import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:responsive_grid/responsive_grid.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
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
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _HeroSection(isDesktop: true)),
                        const SizedBox(width: 40),
                        Expanded(child: _VideoPreview()),
                      ],
                    )
                  : Column(
                      children: [
                        _HeroSection(isDesktop: false),
                        const SizedBox(height: 24),
                        _VideoPreview(),
                      ],
                    ),
            ),
            // _StatsRow(isDesktop: isDesktop),
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
                  const SizedBox(height: 12),
                  Text(
                    'Experience the most comprehensive online bachata program designed to transform you into a confident, passionate dancer.',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _FeaturesGrid(isDesktop: isDesktop),
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

class _LandingAppBar extends StatelessWidget {
  final bool isDesktop;
  const _LandingAppBar({required this.isDesktop});
  @override
  Widget build(BuildContext context) {
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
                      text: 'Only For ',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    TextSpan(
                      text: 'Bachateros',
                      style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isDesktop;
  const _HeroSection({required this.isDesktop});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600 && screenWidth < 975;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level up your Bachata',
          style: TextStyle(
            fontSize: isDesktop ? 40 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Learn new bachata moves and take your bachata journey to the next level',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        isTablet
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      textStyle: TextStyle(fontSize: isDesktop ? 18 : 15, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Start Learning Today'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch Preview'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      textStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      textStyle: TextStyle(fontSize: isDesktop ? 18 : 15, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Start Learning Today'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch Preview'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      textStyle: TextStyle(fontSize: isDesktop ? 16 : 14),
                    ),
                  ),
                ],
              ),
      ],
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

class _StatsRow extends StatelessWidget {
  final bool isDesktop;
  const _StatsRow({required this.isDesktop});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 24 : 16,
        horizontal: isDesktop ? 64 : 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatItem(label: '5+', value: 'Bachata Lessons'),
          const SizedBox(width: 32),
          _StatItem(label: '24/7', value: 'Access'),
          // const SizedBox(width: 32),
          // _StatItem(label: '', value: 'Lifetime Updates'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
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
        title: 'Authentic Bachata Style',
        description: 'Learn traditional Dominican bachata and modern fusion styles from certified instructors.',
      ),
      _FeatureCard(
        icon: Icons.groups,
        title: 'Progressive Learning',
        description: 'Structured curriculum from basic steps to advanced combinations and partner work.',
      ),
      _FeatureCard(
        icon: Icons.access_time,
        title: 'Learn at Your Pace',
        description: "24/7 access to all lessons. Practice when it's convenient for you, anywhere in the world.",
      ),
      _FeatureCard(
        icon: Icons.emoji_events,
        title: 'Expert Instruction',
        description: 'World-renowned bachata dancers and teachers guide you through every movement.',
      ),
      _FeatureCard(
        icon: Icons.favorite,
        title: 'Feel the Passion',
        description: "Connect with the emotional essence of bachata – it's more than just steps, it's expression.",
      ),
      _FeatureCard(
        icon: Icons.public,
        title: 'Global Community',
        description: 'Join thousands of bachata lovers worldwide and share your progress with fellow dancers.',
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
  const _FeatureCard({required this.icon, required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 20),
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
            'Only For Bachateros',
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