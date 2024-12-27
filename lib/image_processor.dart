 import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart'; 


class ImageProcessor {
  ImageProcessor({
    this.crossAxisCount = 4,
    this.mainAxisCount = 4,
  
    required this.assetPath, 
    required this.context,
  });

  final int mainAxisCount;
  final int crossAxisCount;
 
  final String assetPath;
  final BuildContext context;

  /// Load an image from assets and convert it into UI image format
  Future<ui.Image> loadUiImage(String assetPath) async {
    final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Convert a Uint8List image into UI Image format
  Future<ui.Image> loadUiImageFromBytes(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Process the image into grids
  Future<List<Uint8List>> processImageIntoGrids(Uint8List? imageBytes ) async {
    // Load the image: use `imageBytes` if available, otherwise use `assetPath`
    final ui.Image image = imageBytes != null
        ? await loadUiImageFromBytes(imageBytes)
        : await loadUiImage(assetPath);

    final List<Uint8List> gridImages = [];
    final int gridWidth = (image.width / mainAxisCount).floor();
    final int gridHeight = (image.height / crossAxisCount).floor();

    for (int row = 0; row < crossAxisCount; row++) {
      for (int col = 0; col < mainAxisCount; col++) {
        final left = col * gridWidth;
        final top = row * gridHeight;

        // Create a PictureRecorder to draw the sub-image
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final ui.Canvas canvas = Canvas(recorder);

        final paint = Paint();
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(left.toDouble(), top.toDouble(), gridWidth.toDouble(), gridHeight.toDouble()),
          Rect.fromLTWH(0, 0, gridWidth.toDouble(), gridHeight.toDouble()),
          paint,
        );

        // Convert to Image
        final ui.Image subImage =
            await recorder.endRecording().toImage(gridWidth, gridHeight);

        final ByteData? byteData =
            await subImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          gridImages.add(byteData.buffer.asUint8List());
        }
      }
    }

    return gridImages;
  }
}
