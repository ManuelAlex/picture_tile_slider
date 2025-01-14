import 'package:flutter/material.dart';
import 'package:picture_tile_slider/game_tile.dart';
import 'package:picture_tile_slider/helpers.dart';

import 'game_engine.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
    required GameEngine gameEngine,
    required this.onPlayOrPause,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gameItems,
  }) : _gameEngine = gameEngine;

  final GameEngine _gameEngine;
  final VoidCallback onPlayOrPause;
  final int crossAxisCount, mainAxisCount;
  final GameItems gameItems;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    String toDigitsTime(int t) => (t % 60).toString().padLeft(2, '0');
    final Color color = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(4),
      width: MediaQuery.sizeOf(context).width,
      height: 50,
      decoration: const BoxDecoration(color: Colors.lightBlueAccent),
      child: Row(
        children: [
          IconButton(
            tooltip: widget._gameEngine.isPaused
                ? 'Click to play'
                : 'Click to pause',
            onPressed: widget.onPlayOrPause,
            icon: Icon(
              widget._gameEngine.isPaused ? Icons.play_arrow : Icons.pause,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          PreviewMenuButton(
            crossAxisCount: widget.crossAxisCount,
            mainAxisCount: widget.mainAxisCount,
            gameItems: widget.gameItems,
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Enable or disable sound',
            child: IconButton(
              onPressed: () {
                setState(() {
                  widget._gameEngine.soundPlayer.toggleSound();
                });
              },
              icon: Icon(
                widget._gameEngine.soundPlayer.isSoundEnabled
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
              color: color,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<Duration>(
            valueListenable: widget._gameEngine.currentTimeNotifier,
            builder: (context, currentDuration, child) {
              return MinutesAndSecondsText(
                seconds: toDigitsTime(currentDuration.inSeconds),
                minutes: toDigitsTime(currentDuration.inMinutes),
                hour: currentDuration.inHours > 0
                    ? currentDuration.inHours.toString()
                    : '',
              );
            },
          ),
        ],
      ),
    );
  }
}

class PreviewMenuButton extends StatelessWidget {
  const PreviewMenuButton({
    super.key,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gameItems,
  });

  final int crossAxisCount;
  final int mainAxisCount;
  final GameItems gameItems;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Click to view puzzle preview',
      child: MenuAnchor(
        menuChildren: <Widget>[
          SizedBox(
            width: 300,
            height: 300,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              children: List.generate(
                crossAxisCount * mainAxisCount,
                (int index) {
                  return Tile(
                    size: 20,
                    index: index,
                    itemString: switch (gameItems) {
                      GameItems.letter => alphabets[index],
                      GameItems.number => '$index',
                      _ => null,
                    },
                  );
                },
              ),
            ),
          ),
        ],
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: Icon(
              Icons.preview,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          );
        },
      ),
    );
  }
}

class MinutesAndSecondsText extends StatelessWidget {
  const MinutesAndSecondsText({
    super.key,
    required this.minutes,
    required this.seconds,
    required this.hour,
  });

  final String minutes;
  final String seconds;
  final String hour;

  @override
  Widget build(BuildContext context) {
    SizedBox buildFixedSizedText(
      String text, [
      double? width,
    ]) {
      return SizedBox(
        width: width,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        Icon(
          Icons.timer_sharp,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        const SizedBox(width: 4),
        if (hour.isNotEmpty) ...[
          buildFixedSizedText(
            minutes[0],
          ),
          const SizedBox(width: 2),
        ],
        buildFixedSizedText(
          minutes[0],
        ),
        buildFixedSizedText(
          minutes[1],
        ),
        const SizedBox(width: 2),
        buildFixedSizedText(':', 10),
        const SizedBox(width: 2),
        buildFixedSizedText(
          seconds[0],
        ),
        buildFixedSizedText(
          seconds[1],
        ),
      ],
    );
  }
}
