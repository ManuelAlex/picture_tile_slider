
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:picture_tile_slider/game_frame.dart';


import 'helpers.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key,required this.onImagePicked,required this.intialImageData,});
 final void Function(Uint8List? value) onImagePicked;
final Uint8List? intialImageData;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  @override
  void initState() {
 _imageBytes= widget.intialImageData;
    super.initState();
  }

  Uint8List? _imageBytes;
 

  // Function to pick image from device
  Future<void> _pickImage() async {
    try {
     final (Uint8List, String)? imageFile = await pickImageFromGallery();

      if (imageFile != null) {
        final Uint8List bytes =  imageFile.$1; 
                   
       setState(() {
          _imageBytes = bytes;
        });
         widget.onImagePicked(_imageBytes);
         setState(() {
           
         });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

     
    return LayoutBuilder(
  builder: (context, constraints) {
   
    double maxSize = constraints.maxWidth < constraints.maxHeight
        ? constraints.maxWidth
        : constraints.maxHeight;

    
    double imageSize = maxSize.clamp(300, 500);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
    
      children: [
      
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: imageSize,
            maxHeight: imageSize,
          ),
          child: GameFrame(
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _imageBytes!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/fake_mona.jpg',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),

      
        const SizedBox(height: 4),

    
        ElevatedButton.icon(
          onPressed: () {
            setState(() {});
            _pickImage();
          },
          icon: const Icon(Icons.upload_file),
          label: const Text("Choose from File"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        // const SizedBox(height: 16),
      ],
    );
  },
);
  }}