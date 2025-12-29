import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/movie_provider.dart';

class CineFlowSplashPage extends StatefulWidget {
  const CineFlowSplashPage({super.key});

  @override
  State<CineFlowSplashPage> createState() => _CineFlowSplashPageState();
}

class _CineFlowSplashPageState extends State<CineFlowSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Alignment> _logoAlignment;

  late Animation<Offset> _textOffset;
  late Animation<double> _textOpacity;

  final String _title = 'CineFlow';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _logoAlignment = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(-0.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _textOffset = Tween<Offset>(
      begin: const Offset(0.4, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.microtask(() async {
      await Provider.of<MovieProvider>(context, listen: false).loadCatalog();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTypewriterText() {
    final animationValue = _controller.value;

    if (animationValue <= 0.7) {
      return const SizedBox.shrink();
    }

    final t = ((animationValue - 0.7) / 0.3).clamp(0.0, 1.0);
    int lettersToShow = (t * _title.length).toInt() + 1;

    if (lettersToShow > _title.length) {
      lettersToShow = _title.length;
    }

    final visibleText = _title.substring(0, lettersToShow);

    return Text(
      visibleText,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: _logoAlignment.value,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Image.asset(
                        'assets/logo_sombre.png',
                        width: 140,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textOffset,
                    child: Transform.translate(
                      offset: const Offset(-10, 17),
                      child: _buildTypewriterText(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}