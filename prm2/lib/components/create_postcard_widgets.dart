import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:path/path.dart' as path;
import '../models/category.dart';

const Color _darkBg = Color(0xFF2E3239);
const Color _lightShadow = Color(0xFF3A3F47);
const Color _darkShadow = Color(0xFF22252A);
const Color _textColor = Color(0xFFEAEAEA);
const Color _accentColor = Color(0xFF00C6FF);

// --- WIDGET 1: Text Field (Đã cập nhật) ---
class HightechTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode; // Thêm mới
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? errorText; // Thêm mới
  final void Function(String)? onChanged; // Thêm mới
  final void Function(String)? onSubmitted; // Thêm mới

  const HightechTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textColor),
      decoration: InputDecoration(
        errorText: errorText,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: _darkBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _accentColor, width: 2),
        ),
      ),
    );
  }
}

// --- WIDGET 2: File Picker (Giữ nguyên) ---
class FilePickerWidget extends StatelessWidget {
  final String title;
  final XFile? file;
  final IconData icon;
  final VoidCallback onTap;

  const FilePickerWidget({
    super.key,
    required this.title,
    required this.file,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: _textColor, fontSize: 16)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: _darkShadow, offset: Offset(4, 4), blurRadius: 15),
                BoxShadow(color: _lightShadow, offset: Offset(-4, -4), blurRadius: 15),
              ],
            ),
            child: Center(
              child: file == null
                  ? Icon(icon, size: 40, color: _accentColor)
                  : Text(path.basename(file!.path), style: const TextStyle(color: _textColor)),
            ),
          ),
        ),
      ],
    );
  }
}

// --- WIDGET 3: Category Selector (Giữ nguyên) ---
class CategorySelector extends StatefulWidget {
  final String title;
  final List<Category> allCategories;
  final List<Category> selectedCategories;

  const CategorySelector({
    super.key,
    required this.title,
    required this.allCategories,
    required this.selectedCategories,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(color: _textColor, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.allCategories.map((category) {
            final isSelected = widget.selectedCategories.contains(category);
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    widget.selectedCategories.add(category);
                  } else {
                    widget.selectedCategories.remove(category);
                  }
                });
              },
              backgroundColor: _darkBg,
              selectedColor: _accentColor,
              checkmarkColor: _darkBg,
              labelStyle: TextStyle(color: isSelected ? _darkBg : _textColor),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// --- WIDGET 4: Tag Input (Đã cập nhật) ---
class TagInputWidget extends StatelessWidget {
  final TextfieldTagsController controller;
  const TagInputWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFieldTags(
      textfieldTagsController: controller,
      initialTags: const [],
      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      validator: (tag) => tag.isNotEmpty ? null : 'Vui lòng nhập tag.',
      inputFieldBuilder: (context, inputFieldValues) {
        return HightechTextField(
          controller: inputFieldValues.textEditingController,
          focusNode: inputFieldValues.focusNode,
          label: 'Tags (phân cách bởi dấu phẩy hoặc cách)',
          errorText: inputFieldValues.error,
          onChanged: inputFieldValues.onTagChanged,
          onSubmitted: inputFieldValues.onTagSubmitted,
        );
      },
    );
  }
}

// --- WIDGET 5: Stepper Controls (Giữ nguyên) ---
class ControlsWidget extends StatelessWidget {
  final ControlsDetails details;
  final bool isLoading;
  final VoidCallback onSubmit;

  const ControlsWidget({
    super.key,
    required this.details,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (details.currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('QUAY LẠI', style: TextStyle(color: _textColor)),
            ),
          const Spacer(),
          if (details.currentStep < 2)
            ElevatedButton(
              onPressed: details.onStepContinue,
              style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
              child: const Text('TIẾP TỤC'),
            ),
          if (details.currentStep == 2)
            ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                  : const Text('ĐĂNG BÀI'),
            ),
        ],
      ),
    );
  }
}

