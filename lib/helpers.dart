import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


const bool isWeb = bool.fromEnvironment('dart.library.js_util');
const List<String> letters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'  ,
];
List<String> numbers = List.generate(
      220,
      (index) =>index.toString(),
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
  XFile file,) async {
  final List<String> imageExtensions = <String>['jpg', 'jpeg', 'png', 'blob'];

  final String fileExtension = isWeb
      ? file.path
          .split('.')
          .last
          .toLowerCase()
          .split(':')
          .first
          .toLowerCase() 
      : file.path.split('.').last.toLowerCase();



  if (imageExtensions.contains(fileExtension)) {
   return file.readAsBytes();

   
  } 
  return null;
}
    double get borderWidth => 20.0;
     Color  get woodColor => const Color(0xFFA0522D);