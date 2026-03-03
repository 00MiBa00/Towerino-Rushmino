import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final PageController _controller;
  int _pageIndex = 0;
  Timer? _autoAdvanceTimer;
  bool _starting = false;
  String? _startError;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageIndex >= 2) {
        timer.cancel();
        _startAnonymously();
        return;
      }
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startAnonymously() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _startError = null;
    });
    final auth = ref.read(authRepositoryProvider);
    try {
      await auth.signInAnonymously();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _startError = 'Anonymous sign-in failed. Continuing offline.';
      });
    } finally {
      if (!mounted) return;
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B1B2F),
              Color(0xFF162447),
              Color(0xFF1F4068),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _FloatingOrbs(),
              Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Towerino Rushmino',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Build your tower of tasks',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (index) => setState(() {
                        _pageIndex = index;
                        if (index >= 2) {
                          _autoAdvanceTimer?.cancel();
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              _startAnonymously();
                            }
                          });
                        }
                      }),
                      children: [
                        _OnboardingPage(
                          controller: _controller,
                          index: 0,
                          title: 'Catch the spark',
                          subtitle:
                              'Capture tasks in 3 seconds while the idea is hot.',
                          accent: const Color(0xFFF2C94C),
                        ),
                        _OnboardingPage(
                          controller: _controller,
                          index: 1,
                          title: 'Stack the floors',
                          subtitle: 'Every completed task raises your tower.',
                          accent: const Color(0xFF6FCF97),
                        ),
                        _OnboardingPage(
                          controller: _controller,
                          index: 2,
                          title: 'Shine at the top',
                          subtitle:
                              'Watch your progress rise and keep the momentum.',
                          accent: const Color(0xFF56CCF2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PageIndicator(currentIndex: _pageIndex),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _starting ? 1 : 0.7,
                    child: Text(
                      _starting
                          ? 'Starting your tower…'
                          : 'Auto-start in a moment',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  if (_startError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _startError!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.controller,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final PageController controller;
  final int index;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.hasClients
            ? controller.page ?? controller.initialPage.toDouble()
            : 0.0;
        final distance = (page - index).abs().clamp(0.0, 1.0);
        final scale = 1.0 - (distance * 0.08);
        final opacity = 1.0 - (distance * 0.4);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TowerPreview(accent: accent),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TowerPreview extends StatelessWidget {
  const _TowerPreview({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accent.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
          _TowerBlocks(accent: accent),
        ],
      ),
    );
  }
}

class _TowerBlocks extends StatefulWidget {
  const _TowerBlocks({required this.accent});

  final Color accent;

  @override
  State<_TowerBlocks> createState() => _TowerBlocksState();
}

class _TowerBlocksState extends State<_TowerBlocks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = (0.5 + 0.5 * Curves.easeInOut.transform(_controller.value));
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _Block(
              color: widget.accent.withOpacity(0.9),
              width: 160,
              height: 28 + (wave * 2),
            ),
            Positioned(
              bottom: 34,
              child: _Block(
                color: widget.accent.withOpacity(0.75),
                width: 140,
                height: 26 + (wave * 1.5),
              ),
            ),
            Positioned(
              bottom: 66,
              child: _Block(
                color: widget.accent.withOpacity(0.6),
                width: 120,
                height: 24 + (wave * 1.2),
              ),
            ),
            Positioned(
              bottom: 96,
              child: _Block(
                color: widget.accent.withOpacity(0.5),
                width: 100,
                height: 22 + (wave),
              ),
            ),
            Positioned(
              bottom: 122,
              child: _Block(
                color: widget.accent.withOpacity(0.4),
                width: 80,
                height: 20 + (wave * 0.8),
              ),
            ),
            Positioned(
              bottom: 146,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.6),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.auto_awesome, color: widget.accent, size: 22),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.color, required this.width, required this.height});

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE94560) : Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _FloatingOrbs extends StatelessWidget {
  const _FloatingOrbs();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: const [
            _Orb(
              alignment: Alignment(-0.9, -0.8),
              size: 120,
              color: Color(0x33F2C94C),
            ),
            _Orb(
              alignment: Alignment(0.8, -0.6),
              size: 160,
              color: Color(0x3356CCF2),
            ),
            _Orb(
              alignment: Alignment(0.9, 0.7),
              size: 140,
              color: Color(0x336FCF97),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.alignment, required this.size, required this.color});

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
