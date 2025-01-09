import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:picture_tile_slider/floating_button.dart';

import 'package:picture_tile_slider/game_engine.dart';
import 'package:picture_tile_slider/game_frame.dart';
import 'package:picture_tile_slider/game_menu.dart';

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
  Offset _offset = const Offset(100, 100);
  bool _showHiddenBox = false;

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
    final Size size = MediaQuery.sizeOf(context);
    final bool isMobile = size.width < 600;
    double borderWidth = isMobile ? 40 : 80.0;

    final double screenWidth = size.width;
    final double screenHeight = size.height - 60;

    final double maxSize =
        screenWidth < screenHeight ? screenWidth : screenHeight;

    final double constrainedSize = maxSize.clamp(400.0, 1200.0);
    const Color woodColor = Color(0xFFA0522D);

    if (_isProcessing || _gameItemVariable == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final double cardWidth =
        ((constrainedSize - borderWidth * 2) / _crossAxisCount);
    final double borderTolerance = isMobile ? 20 : 0;
    final double cardHeight =
        (((constrainedSize - borderWidth * 2) / _mainAxisCount) -
            borderTolerance);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TopBar(
                  gameEngine: _gameEngine,
                  onPlayOrPause: _onDragTap,
                  gameItems: _gameItem,
                  crossAxisCount: _crossAxisCount,
                  mainAxisCount: _mainAxisCount,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constrainedSize,
                    maxHeight: constrainedSize,
                    minWidth: 400,
                    minHeight: 400,
                  ),
                  child: Stack(
                    children: [
                      GameFrame(
                        child:
                            //GameBoard loosing some states will debug later
                            //GameBoard(items: _gameItemVariable!, gameEngine: _gameEngine, isRandomized: _isRandomized, gameItems: _gameItem, tileHeight: cardHeight, tileWidth: cardWidth),

                            Stack(
                          children: _gameItemVariable!.items
                              .asMap()
                              .entries
                              .map((entry) {
                            final int index = entry.key;
                            // print(index);
                            final dynamic currentItem = entry.value;
                            final bool isDragged =
                                _gameItemVariable!.dragItemIndex != -1 &&
                                    _gameItemVariable!.dragItemIndex == index;

                            Offset getTileOffset(int index) {
                              final row =
                                  index ~/ _gameItemVariable!.crossAxisCount;
                              final column =
                                  index % _gameItemVariable!.crossAxisCount;
                              return Offset(
                                  column * cardWidth, row * cardHeight);
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

                                  _gameItemVariable!
                                      .swapItem(!_gameEngine.isPaused, index);

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
                                        height: cardHeight,
                                        width: cardWidth,
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
                                        cardHeight: cardHeight,
                                        cardWidth: cardWidth,
                                        showSelectedIndex: isDragged,
                                        gameItems: _gameItem,
                                        index: tileItems.indexOf(currentItem),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Visibility(
                        visible: _showHiddenBox,
                        child: AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.decelerate,
                          right: borderWidth,
                          left: _showHiddenBox
                              ? (isMobile
                                  ? 0
                                  : (size.width * 0.4) - borderWidth * 2)
                              : size.width - borderWidth * 2,
                          bottom: isMobile ? borderWidth : borderWidth,
                          top: isMobile ? borderWidth : borderWidth,
                          child: Container(
                            margin: EdgeInsets.only(left: borderWidth),
                            child: GameMenu(
                              gameEngine: _gameEngine,
                              intialImageData: _imageBytes,
                              selectedItem: _gameItem,
                              size: size,
                              woodColor: woodColor,
                              mainAxisCount: _mainAxisCount,
                              crossAxisCount: _crossAxisCount,
                              onCrossAxisSelected: (int newNumer) => _setter(
                                () => _crossAxisCount = newNumer,
                              ),
                              onMainAxisSelected: (int newNumer) =>
                                  _setter(() => _mainAxisCount = newNumer),
                              onImagePicked: (Uint8List? newImageData) {
                                if (newImageData != null) {
                                  _setter(() => _imageBytes = newImageData);
                                }
                              },
                              onGameItemSelected: (GameItems newItem) =>
                                  _setter(() => _gameItem = newItem),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: _offset.dy,
                        left: _offset.dx,
                        child: FloatingButton(
                          onTap: () {
                            setState(() {
                              _showHiddenBox = !_showHiddenBox;
                            });
                          },
                          onDragEnd: (Offset details) {
                            setState(() {
                              _offset = details;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
