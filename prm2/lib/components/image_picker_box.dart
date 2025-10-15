import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';

// COMPONENT: Vùng chọn ảnh
class ImagePickerBox extends StatelessWidget {
  final XFile? imageFile;
  final VoidCallback onTap;

  const ImagePickerBox({super.key, required this.imageFile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kHighlightColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kInputBorderColor, width: 1.5),
        ),
        child: imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(imageFile!.path),
            fit: BoxFit.cover,
          ),
        )
            : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 50, color: kAccentColor),
            SizedBox(height: 8),
            Text('Chạm để chọn ảnh', style: TextStyle(color: kPrimaryTextColor)),
          ],
        ),
      ),
    );
  }
}
