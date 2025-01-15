import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picture_tile_slider/game_tile.dart';
import 'package:picture_tile_slider/helpers.dart';
import 'package:picture_tile_slider/items.dart';

import 'game_engine.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
    required GameEngine gameEngine,
    required this.onPlayOrPause,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gameItems,
    required this.items,
    required this.restart,
    required this.onGridSelected,
    required this.onGameItemSelected,
    required this.onImageSelected,
    required this.imageByte,
  }) : _gameEngine = gameEngine;

  final GameEngine _gameEngine;
  final VoidCallback onPlayOrPause, restart;
  final int crossAxisCount, mainAxisCount;
  final GameItems gameItems;
  final Items items;
  final ValueChanged<int?> onGridSelected;
  final ValueChanged<GameItems?> onGameItemSelected;
  final ValueChanged<Uint8List?> onImageSelected;
  final Uint8List? imageByte;

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
        //height: 100,
        decoration: const BoxDecoration(color: Colors.lightBlueAccent),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Wrap(
                children: [
                  IconButton(
                    tooltip: widget._gameEngine.isPaused
                        ? 'Click to play'
                        : 'Click to pause',
                    onPressed: widget.onPlayOrPause,
                    icon: Icon(
                      widget._gameEngine.isPaused
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PreviewMenuButton(
                    crossAxisCount: widget.crossAxisCount,
                    mainAxisCount: widget.mainAxisCount,
                    gameItems: widget.gameItems,
                    imageByte: widget.imageByte,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Enable or disable',
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
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Restart',
                    onPressed: widget.restart,
                    icon: Icon(
                      Icons.replay,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 145,
                    child: DropdownMenuTheme(
                      data: DropdownMenuThemeData(
                        textStyle: TextStyle(color: color),
                      ),
                      child: DropdownMenu(
                        initialSelection: 3,
                        leadingIcon: const Icon(Icons.grid_4x4),
                        enableSearch: true,
                        keyboardType: TextInputType.text,
                        inputDecorationTheme: InputDecorationTheme(
                          iconColor: color,
                          prefixIconColor: color,
                          suffixIconColor: color,
                          enabledBorder: InputBorder.none,
                          prefixStyle: const TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: color),
                          labelStyle: TextStyle(color: color),
                        ),
                        onSelected: widget.onGridSelected,
                        dropdownMenuEntries: List.generate(8, (int index) {
                          final int startIndex = index + 3;
                          final String gridLabel = '$startIndex x $startIndex';
                          return DropdownMenuEntry(
                            value: startIndex,
                            label: gridLabel,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 145,
                    child: DropdownMenuTheme(
                      data: DropdownMenuThemeData(
                        textStyle: TextStyle(color: color),
                      ),
                      child: DropdownMenu<GameItems>(
                        initialSelection: GameItems.letter,
                        leadingIcon: Icon(switch (widget.gameItems) {
                          GameItems.letter => Icons.abc_outlined,
                          GameItems.number => Icons.numbers_outlined,
                          GameItems.image => Icons.image,
                        }),
                        enableSearch: true,
                        keyboardType: TextInputType.text,
                        inputDecorationTheme: InputDecorationTheme(
                          iconColor: color,
                          prefixIconColor: color,
                          suffixIconColor: color,
                          enabledBorder: InputBorder.none,
                          prefixStyle: const TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: color),
                          labelStyle: TextStyle(color: color),
                        ),
                        dropdownMenuEntries:
                            GameItems.values.map((GameItems value) {
                          return DropdownMenuEntry<GameItems>(
                            value: value,
                            label: value.name[0].toUpperCase() +
                                value.name.substring(1),
                          );
                        }).toList(),
                        onSelected: widget.onGameItemSelected,
                      ),
                    ),
                  ),
                  if (widget.gameItems == GameItems.image) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () async {
                        final (Uint8List, String)? imageItem =
                            await pickImageFromGallery();
                        widget.onImageSelected(imageItem?.$1);
                      },
                      icon: Row(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          Text(
                            'Upload',
                            style: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
            ),
          ],
        ));
  }
}

class PreviewMenuButton extends StatelessWidget {
  const PreviewMenuButton({
    super.key,
    required this.crossAxisCount,
    required this.mainAxisCount,
    required this.gameItems,
    required this.imageByte,
  });

  final int crossAxisCount;
  final int mainAxisCount;
  final GameItems gameItems;
  final Uint8List? imageByte;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Click to view puzzle preview',
      child: MenuAnchor(
        menuChildren: <Widget>[
          SizedBox(
            width: 300,
            height: 300,
            child: gameItems == GameItems.image
                ? imageByte != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          imageByte!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/fake_mona.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                : GridView.count(
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
