import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const bool isWeb = bool.fromEnvironment('dart.library.js_util');
const List<String> letters = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
];
List<String> numbers = List.generate(
  220,
  (index) => index.toString(),
);
final List<String> alphabets = [...letters, ...numbers];
Future<(Uint8List, String)?> pickImageFromGallery() async {
  // note on web
  // Once the user has picked a file, the returned XFile instance will contain
  // a network-accessible Blob URL (pointing to a location within the browser).
  //The instance will also let you retrieve the bytes of the selected file across all platforms.

  XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (file == null) {
    return null;
  }

  final Uint8List? image = await loadImageFromFile(
    file,
  );

  if (image == null) {
    return null;
  }

  return (image, file.name);
}

Future<Uint8List?> loadImageFromFile(
  XFile file,
) async {
  final List<String> imageExtensions = <String>['jpg', 'jpeg', 'png', 'blob'];

  final String fileExtension = isWeb
      ? file.path.split('.').last.toLowerCase().split(':').first.toLowerCase()
      : file.path.split('.').last.toLowerCase();

  if (imageExtensions.contains(fileExtension)) {
    return enforceImageDimensions(await file.readAsBytes());
  }
  return null;
}

double get borderWidth => 20.0;
Color get woodColor => const Color(0xFFA0522D);

/// Resize an image to fit within the specified dimensions.
Uint8List enforceImageDimensions(
  Uint8List imageBytes, {
  int maxWidth = 600,
  int maxHeight = 600,
}) {
  final img.Image? image = img.decodeImage(imageBytes);
  if (image == null) {
    return imageBytes;
  }

  int width = image.width;
  int height = image.height;

  if (width <= maxWidth && height <= maxHeight) {
    return imageBytes;
  }

  final double aspectRatio = width / height;

  if (width > maxWidth) {
    width = maxWidth;
    height = (width / aspectRatio).round();
  }

  if (height > maxHeight) {
    height = maxHeight;
    width = (height * aspectRatio).round();
  }

  final img.Image resizedImage =
      img.copyResize(image, width: width, height: height);
  return Uint8List.fromList(img.encodeJpg(resizedImage));
}
