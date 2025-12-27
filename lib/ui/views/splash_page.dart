import 'package:flutter/material.dart';

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

  // pour l'effet lettre par lettre
  final String _title = 'CineFlow';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // 0.0 -> 0.4 : logo pop + fade au centre
    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    // 0.7 -> 1.0 : logo glisse du centre vers la gauche
    _logoAlignment = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(-0.5, 0.0), // un peu plus à gauche
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Texte qui apparaît à droite après le déplacement du logo
    _textOffset = Tween<Offset>(
      begin: const Offset(0.4, 0.0), // léger slide depuis la droite
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

    // Aller vers Home une fois l'animation terminée
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

  // construit le texte "CineFlow" lettre par lettre
  Widget _buildTypewriterText() {
    final animationValue = _controller.value;

    if (animationValue <= 0.7) {
      return const SizedBox.shrink(); // rien avant la phase texte
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
                // Logo (aligné horizontalement, mais déplacé par AlignmentTween)
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

                // Texte CineFlow à côté du logo
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textOffset,
                    child: Transform.translate(
                      // ajuste ici pour monter/descendre ou décaler le texte
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
