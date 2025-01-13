import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'game_engine.dart';
import 'game_tile.dart';
import 'items.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.items,
    required this.gameEngine,
    required this.isRandomized,
    required this.gameItems,
    required this.tileHeight,
    required this.tileWidth,
    required this.index,
  });

  final Items<dynamic> items;
  final GameEngine gameEngine;
  final GameItems gameItems;
  final bool isRandomized;
  final double tileHeight, tileWidth;
  final int index;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late bool _isRandomized;
  List<dynamic> tileItems = [];
  bool isAnimating = false;
  @override
  void initState() {
    _isRandomized = widget.isRandomized;
    tileItems = List.from(widget.items.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.items.items.asMap().entries.map((entry) {
        final int index = entry.key;
        final dynamic currentItem = entry.value;
        final bool isDragged = widget.items.dragItemIndex == index;
        final Offset offset = _getTileOffset(tileItems.indexOf(currentItem));

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: offset.dy,
          left: offset.dx,
          child: GestureDetector(
            onTap: () => _handleTileTap(index),
            child: _buildTileContent(index, currentItem, isDragged),
          ),
        );
      }).toList(),
    );
  }

  Offset _getTileOffset(int index) {
    final row = index ~/ widget.items.crossAxisCount;
    final column = index % widget.items.crossAxisCount;
    return Offset(column * widget.tileWidth, row * widget.tileHeight);
  }

  void _handleTileTap(int index) {
    if (isAnimating) return; // Prevent multiple animations
    setState(() {
      isAnimating = true; // Set animation flag to true
    });

    widget.items.swapItem(!widget.gameEngine.isPaused, index, () {});

    // Trigger the state update after animation completes
    Future.delayed(const Duration(milliseconds: 90), () {
      setState(() {
        tileItems = List.from(widget.items.items);
        isAnimating = false;
      });
    });
  }

  Widget _buildTileContent(int index, dynamic currentItem, bool isDragged) {
    if (index == widget.items.dragItemIndex) {
      return InkWell(
        onTap: () {
          setState(() {
            if (widget.gameEngine.isPaused) {
              if (!_isRandomized) {
                widget.items.randomizeItems();
                _isRandomized = true;
              }
              widget.gameEngine.play();
            } else {
              widget.gameEngine.pause();
            }
            tileItems = List.from(widget.items.items);
            isAnimating = false;
          });
        },
        child: Container(
          height: widget.tileHeight,
          width: widget.tileWidth,
          color: Colors.black12,
          child: Center(
            child: Text(
              widget.gameEngine.isPaused ? 'PLAY' : 'PAUSE',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return GameTile(
      itemImage: currentItem is Uint8List ? currentItem : null,
      itemString: currentItem is String ? currentItem : null,
      cardHeight: widget.tileHeight,
      cardWidth: widget.tileWidth,
      showSelectedIndex: isDragged,
      gameItems: widget.gameItems,
      index: widget.index,
      isPaused: widget.gameEngine.isPaused,
    );
  }
}
