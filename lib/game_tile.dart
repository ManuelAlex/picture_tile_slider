import 'dart:typed_data';

import 'package:flutter/material.dart';

enum GameItems { letter, number, image }

class GameTile extends StatelessWidget {
  const GameTile({
    super.key,
    this.itemImage,
    this.itemString,
    this.itemInteger,
    required this.cardHeight,
    required this.cardWidth,
    required this.showSelectedIndex,
    required this.gameItems,
    this.borderColor,
    required this.index,
    required this.isPaused,
  }) : assert(
          itemImage != null || itemString != null || itemInteger != null,
          'Either itemImage or itemString must be provided.',
        );

  final Uint8List? itemImage;
  final double cardHeight;
  final double cardWidth;
  final bool showSelectedIndex;
  final GameItems gameItems;
  final String? itemString;
  final int? itemInteger;
  final Color? borderColor;
  final int index;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    const Color woodColor = Color(0xFFA0522D);

    return Tooltip(
      message: isPaused ? 'Tap on the play button to swipe' : '',
      child: Container(
        height: cardHeight,
        width: cardWidth,
        decoration:
            BoxDecoration(border: Border.all(color: borderColor ?? woodColor)),
        child:
            //showSelectedIndex
            // ? Container(
            //     color: Colors.black12,
            //   )
            // :
            switch (gameItems) {
          GameItems.image => itemImage != null
              ? Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length],
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          offset: Offset(-2, -2),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ]),
                  child: Image.memory(
                    itemImage!,
                    fit: BoxFit.fill,
                  ),
                )
              : const SizedBox.shrink(),
          GameItems.letter => itemString != null
              ? Tile(index: index, itemString: itemString)
              : const SizedBox.shrink(),
          GameItems.number => itemString != null
              ? Tile(index: index, itemString: itemString)
              : const SizedBox.shrink(),
        },
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile(
      {super.key, required this.index, required this.itemString, this.size});

  final int index;
  final String? itemString;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isMobile = mediaQuery.size.width < 600;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.primaries[index % Colors.primaries.length],
          boxShadow: const [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 3,
              spreadRadius: 1,
            ),
            BoxShadow(
              offset: Offset(-2, -2),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ]),
      child: Center(
        child: Center(
          child: Text(
            itemString!,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: '',
                fontSize: size ??
                    (isMobile
                        ? itemString!.length > 1
                            ? 20
                            : 22
                        : 50),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
