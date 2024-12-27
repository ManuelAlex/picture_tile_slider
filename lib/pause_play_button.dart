import 'package:flutter/material.dart';

import 'game_engine.dart';

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    required GameEngine gameEngine,
    required this.isMobile,
  }) : _gameEngine = gameEngine;

  final double cardHeight;
  final double cardWidth;
  final GameEngine _gameEngine;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      width: cardWidth,
      color: Colors.black12,
      child: Center(
        child: Text(
          _gameEngine.isPaused ? 'PLAY' : 'PAUSE',
          style:  TextStyle(
              fontSize:isMobile?20: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}