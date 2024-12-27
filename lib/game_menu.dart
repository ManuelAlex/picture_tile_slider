import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:picture_tile_slider/helpers.dart';
import 'package:picture_tile_slider/game_engine.dart';
import 'package:picture_tile_slider/game_frame.dart';
import 'package:picture_tile_slider/game_tile.dart';
import 'package:picture_tile_slider/image_picker_widget.dart';
import 'package:picture_tile_slider/number_selector.dart';

class GameMenu extends StatefulWidget {
  const GameMenu({
    super.key,
    required this.size,
    required this.woodColor,
    required this.onGameItemSelected,
    required this.selectedItem,
    required this.onCrossAxisSelected,
    required this.onMainAxisSelected,
    required this.onImagePicked,
    required this.intialImageData,
    required this.gameEngine,
    required this.crossAxisCount,
    required this.mainAxisCount,
  
  });

  final Size size;
  final Color woodColor;
  final GameItems selectedItem;
  final ValueChanged<GameItems> onGameItemSelected;
  final ValueChanged<int>onCrossAxisSelected;
    final ValueChanged<int>onMainAxisSelected;
       final void Function(Uint8List? value) onImagePicked;
       final Uint8List? intialImageData;
       final GameEngine gameEngine;
       final int crossAxisCount,mainAxisCount;
      

  @override
  State<GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  late GameItems _gameItem;

  @override
  void initState() {
    super.initState();
    _gameItem = widget.selectedItem; 

  }

  @override
  Widget build(BuildContext context) {
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final  bool isMobile = mediaQuery.size.width < 600; 
  final double maxHeight = mediaQuery.size.height; 
  final double maxWidth = mediaQuery.size.width; 

  return Container(
    height: maxHeight - 160, 
    width: isMobile ? maxWidth - 16 : maxWidth * 0.6 + 8,
    decoration: BoxDecoration(
      color: widget.woodColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      border: Border.all(width: 8),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20,),
         
          SegmentedButton<GameItems>(
            segments: const <ButtonSegment<GameItems>>[
              ButtonSegment<GameItems>(
                value: GameItems.letter,
                label: Text('Letter'),
                icon: Icon(Icons.abc),
              ),
              ButtonSegment<GameItems>(
                value: GameItems.number,
                label: Text('Number'),
                icon: Icon(Icons.numbers),
              ),
              ButtonSegment<GameItems>(
                value: GameItems.image,
                label: Text('Image'),
                icon: Icon(Icons.image),
              ),
            ],
            selected: <GameItems>{_gameItem},
            onSelectionChanged: (Set<GameItems> newSelection) {
              setState(() {
                _gameItem = newSelection.first;
              });
              widget.onGameItemSelected(_gameItem);
            },
          ),
          const SizedBox(height: 16),
          
          
          if (_gameItem == GameItems.image)
            ImagePickerWidget(
              onImagePicked: widget.onImagePicked,
              intialImageData: widget.intialImageData,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
              
                double maxSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;

                double size = maxSize.clamp(200, isMobile ? 300 : 500);

                return Center(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: GameFrame(
                      child: GridView.count(
                        crossAxisCount: widget.crossAxisCount,
                        children: List.generate(
                          widget.crossAxisCount * widget.mainAxisCount,
                          (int index) {
                            return Tile(
                              index: index,
                              itemString: switch (_gameItem) {
                                GameItems.letter => alphabets[index],
                                GameItems.number => '$index',
                                _ => null,
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 16),
          
        
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('Cross axis count'),
              NumberPicker(
                onSelected: widget.onCrossAxisSelected,
                initialValue: widget.crossAxisCount,
              ),
              const Text('Main axis count'),
              NumberPicker(
                onSelected: widget.onMainAxisSelected,
                initialValue: widget.mainAxisCount,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}