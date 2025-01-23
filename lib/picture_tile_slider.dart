// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:picture_tile_slider/game_engine.dart';
import 'package:picture_tile_slider/game_frame.dart';

import 'helpers.dart';

import 'game_tile.dart';
import 'image_processor.dart';
import 'items.dart';

import 'top_bar.dart';

class PictureTileSlider extends StatefulWidget {
  const PictureTileSlider({super.key});

  @override
  State<PictureTileSlider> createState() => _PictureTileSliderState();
}

class _PictureTileSliderState extends State<PictureTileSlider> {
  late Items<dynamic>? _gameItemVariable;
  bool _isProcessing = true;
  GameItems _gameItem = GameItems.letter;
  int _crossAxisCount = 4;
  int _mainAxisCount = 4;
  Uint8List? _imageBytes;
  final GameEngine _gameEngine = GameEngine();
  bool _isRandomized = false;
  bool isAnimating = false;

  List<dynamic> tileItems = [];

  @override
  void initState() {
    super.initState();

    _initializeGrid();
  }

  @override
  void dispose() {
    _gameEngine.stop();
    super.dispose();
  }

  Future<void> _initializeGrid() async {
    _gameEngine.stop();

    try {
      final ImageProcessor processor = ImageProcessor(
        assetPath: 'assets/images/fake_mona.jpg',
        context: context,
        crossAxisCount: _crossAxisCount,
        mainAxisCount: _mainAxisCount,
      );

      final List<Uint8List> image = _gameItem == GameItems.image
          ? await processor.processImageIntoGrids(_imageBytes)
          : [];

      setState(() {
        _gameItemVariable = switch (_gameItem) {
          GameItems.image =>
            Items<Uint8List>(itemBuilder: (index) => image[index]),
          GameItems.letter =>
            Items<String>(itemBuilder: (index) => alphabets[index]),
          GameItems.number =>
            Items<String>(itemBuilder: (index) => index.toString()),
        };
        _gameItemVariable!
            .updateGridDimensions(_crossAxisCount, _mainAxisCount);
        tileItems = _gameItemVariable!.items;
        _isRandomized = false;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing || _gameItemVariable == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    var topBar = TopBar(
      gameEngine: _gameEngine,
      items: _gameItemVariable!,
      imageByte: _imageBytes,
      onPlayOrPause: _onDragTap,
      restart: () {
        _gameEngine.soundPlayer.reset();
        _initializeGrid();
      },
      onGridSelected: _onGridSelected,
      onGameItemSelected: _onGameItemSelected,
      onImageSelected: _onImageSelected,
      gameItems: _gameItem,
      crossAxisCount: _crossAxisCount,
      mainAxisCount: _mainAxisCount,
    );
    return SafeArea(
      child: Scaffold(
        appBar: topBar,
        bottomNavigationBar: BottomBar(
          onGameItemSelected: _onGameItemSelected,
          onGridSelected: _onGridSelected,
          onImageSelected: _onImageSelected,
          gameItems: _gameItem,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  final Size size = constraints.biggest;
                  final bool isMobile = size.width < 600;
                  final double borderWidth = isMobile ? 20 : 80.0;

                  final double screenWidth = size.width;
                  final double screenHeight = size.height;

                  final double maxSize =
                      screenWidth < screenHeight ? screenWidth : screenHeight;
                  final double constrainedSize =
                      maxSize.clamp(400.0, 1200.0) - (isMobile ? 40 : 200);

                  final double cardSize =
                      constrainedSize / max(_crossAxisCount, _mainAxisCount) -
                          (borderWidth * 2) / _crossAxisCount;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constrainedSize,
                        maxHeight: constrainedSize,
                      ),
                      child: GameFrame(
                        child: Stack(
                          children: _gameItemVariable!.items
                              .asMap()
                              .entries
                              .map((entry) {
                            final int index = entry.key;
                            final dynamic currentItem = entry.value;
                            final bool isDragged =
                                _gameItemVariable!.dragItemIndex != -1 &&
                                    _gameItemVariable!.dragItemIndex == index;

                            Offset getTileOffset(int index) {
                              final row =
                                  index ~/ _gameItemVariable!.crossAxisCount;
                              final column =
                                  index % _gameItemVariable!.crossAxisCount;
                              return Offset(column * cardSize, row * cardSize);
                            }

                            final Offset offset =
                                getTileOffset(tileItems.indexOf(currentItem));

                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              top: offset.dy,
                              left: offset.dx,
                              curve: Curves.decelerate,
                              child: GestureDetector(
                                onTap: () {
                                  if (isAnimating) return;
                                  setState(() {
                                    isAnimating = true;
                                  });

                                  _gameItemVariable!.swapItem(
                                      !_gameEngine.isPaused, index, () {
                                    if (!isDragged) {
                                      _gameEngine.soundPlayer.play();
                                    }
                                  });

                                  Future.delayed(
                                      const Duration(milliseconds: 90), () {
                                    setState(() {
                                      tileItems =
                                          List.from(_gameItemVariable!.items);
                                      isAnimating = false;
                                    });
                                  });
                                },
                                child: isDragged
                                    ? Container(
                                        height: cardSize,
                                        width: cardSize,
                                        color: Colors.transparent,
                                      )
                                    : GameTile(
                                        isPaused: _gameEngine.isPaused,
                                        itemImage: currentItem is Uint8List
                                            ? currentItem
                                            : null,
                                        itemString: currentItem is String
                                            ? currentItem
                                            : null,
                                        cardHeight: cardSize,
                                        cardWidth: cardSize,
                                        showSelectedIndex: isDragged,
                                        gameItems: _gameItem,
                                        index: tileItems.indexOf(currentItem),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onImageSelected(Uint8List? newImage) {
    if (newImage != null) {
      _setter(() => _imageBytes = newImage);
    }
  }

  void _onGridSelected(int? gridNumber) {
    if (gridNumber != null) {
      _setter(() {
        _crossAxisCount = gridNumber;
        _mainAxisCount = gridNumber;
      });
    }
  }

  void _onGameItemSelected(GameItems? gameItem) {
    if (gameItem != null) {
      _setter(() {
        _gameItem = gameItem;
      });
    }
  }

  void _setter(VoidCallback fn) {
    setState(() {
      fn();
      _isProcessing = true;
    });
    _initializeGrid();
  }

  void _onDragTap() {
    setState(() {
      if (_gameEngine.isPaused) {
        if (!_isRandomized) {
          _gameItemVariable?.randomizeItems();
          _isRandomized = true;
        }
        _gameEngine.play();
      } else {
        _gameEngine.pause();
      }

      tileItems = List.from(_gameItemVariable!.items);
      isAnimating = false;
    });
  }
}
