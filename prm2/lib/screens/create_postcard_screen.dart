import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class PodcastUploadScreen extends StatefulWidget {
  const PodcastUploadScreen({super.key});

  @override
  State<PodcastUploadScreen> createState() => _PodcastUploadScreenState();
}

class _PodcastUploadScreenState extends State<PodcastUploadScreen> {
  // --- STATE MANAGEMENT ---
  int _currentStep = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seriesNameController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _episodeNumberController = TextEditingController();
  final _hostNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _transcriptUrlController = TextEditingController();

  // State for file data
  Uint8List? _thumbnailBytes;
  String? _thumbnailName;
  Uint8List? _audioBytes;
  String? _audioName;

  // --- THAY ĐỔI: Sử dụng danh sách danh mục cứng ---
  final List<Category> _allTopicCategories = [
    Category(id: 1, name: 'Giáo dục'),
    Category(id: 2, name: 'Giải trí'),
    Category(id: 3, name: 'Kinh doanh'),
    Category(id: 4, name: 'Công nghệ'),
    Category(id: 5, name: 'Đời sống'),
    Category(id: 6, name: 'Thể thao'),
  ];

  final List<Category> _allEmotionCategories = [
    Category(id: 1, name: 'Vui vẻ'),
    Category(id: 2, name: 'Sâu lắng'),
    Category(id: 3, name: 'Thư giãn'),
    Category(id: 4, name: 'Tò mò'),
    Category(id: 5, name: 'Động lực'),
    Category(id: 6, name: 'Hài hước'),
  ];

  final List<int> _selectedTopicIds = [];
  final List<int> _selectedEmotionIds = [];


  @override
  void initState() {
    super.initState();
    // Không cần gọi _fetchCategories nữa
  }

  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _seriesNameController.dispose();
    _guestNameController.dispose();
    _episodeNumberController.dispose();
    _hostNameController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    _transcriptUrlController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  // Xóa hàm _fetchCategories

  Future<void> _pickThumbnail() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _thumbnailBytes = bytes;
        _thumbnailName = image.name;
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _audioBytes = result.files.single.bytes;
        _audioName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadPodcast() async {
    // Basic validation
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _thumbnailBytes == null || _audioBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền các thông tin cơ bản và chọn file')));
      return;
    }
    if (_selectedTopicIds.isEmpty || _selectedEmotionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất một danh mục cho mỗi loại')));
      return;
    }

    final episodeNumber = int.tryParse(_episodeNumberController.text);
    final duration = int.tryParse(_durationController.text);

    setState(() { _isLoading = true; });

    final result = await _apiService.createPodcast(
      title: _titleController.text,
      description: _descriptionController.text,
      thumbnailBytes: _thumbnailBytes!,
      thumbnailFileName: _thumbnailName!,
      audioBytes: _audioBytes!,
      audioFileName: _audioName!,
      seriesName: _seriesNameController.text,
      guestName: _guestNameController.text,
      episodeNumber: episodeNumber ?? 0,
      hostName: _hostNameController.text,
      duration: duration ?? 0,
      tags: _tagsController.text,
      transcriptUrl: _transcriptUrlController.text,
      topicCategoryIds: _selectedTopicIds,
      emotionCategoryIds: _selectedEmotionIds,
    );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng bài thành công!')));
        Navigator.pop(context, true); // Return true to refresh dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result.message ?? "Có lỗi xảy ra"}')));
      }
    }

    setState(() { _isLoading = false; });
  }

  // --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Tạo Postcard Mới', style: TextStyle(color: kPrimaryTextColor)),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: kAccentColor)) : Theme(
        data: Theme.of(context).copyWith(
          canvasColor: kBackgroundColor,
          colorScheme: const ColorScheme.dark(
            primary: kAccentColor,
            onPrimary: kPrimaryTextColor,
            surface: kCardBackgroundColor,
            onSurface: kPrimaryTextColor,
          ),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _uploadPodcast();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
                    child: Text(_currentStep == 2 ? 'ĐĂNG BÀI' : 'TIẾP TỤC', style: const TextStyle(color: kPrimaryTextColor)),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep != 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('QUAY LẠI', style: TextStyle(color: kSecondaryTextColor)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Thông tin cơ bản'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            _buildTextField(_titleController, 'Tiêu đề*'),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, 'Mô tả*', maxLines: 3),
            const SizedBox(height: 16),
            _buildFilePicker(
              title: 'Ảnh bìa (Thumbnail)*',
              fileName: _thumbnailName,
              onPressed: _pickThumbnail,
              icon: Icons.image,
              preview: _thumbnailBytes != null ? Image.memory(_thumbnailBytes!, fit: BoxFit.cover) : null,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Chi tiết & Media'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            _buildTextField(_seriesNameController, 'Tên Series'),
            const SizedBox(height: 16),
            _buildTextField(_guestNameController, 'Tên khách mời'),
            const SizedBox(height: 16),
            _buildTextField(_hostNameController, 'Tên Host'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_episodeNumberController, 'Số tập', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_durationController, 'Thời lượng (giây)', keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              title: 'File Âm thanh*',
              fileName: _audioName,
              onPressed: _pickAudio,
              icon: Icons.audio_file,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Phân loại'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryPicker(
              title: 'Danh mục chủ đề*',
              allCategories: _allTopicCategories,
              selectedIds: _selectedTopicIds,
            ),
            const SizedBox(height: 16),
            _buildCategoryPicker(
              title: 'Danh mục cảm xúc*',
              allCategories: _allEmotionCategories,
              selectedIds: _selectedEmotionIds,
            ),
            const SizedBox(height: 16),
            _buildTextField(_tagsController, 'Tags (cách nhau bởi dấu phẩy)'),
            const SizedBox(height: 16),
            _buildTextField(_transcriptUrlController, 'URL Transcript'),
          ],
        ),
      ),
    ];
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: kPrimaryTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kSecondaryTextColor),
        filled: true,
        fillColor: kCardBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kAccentColor)),
      ),
    );
  }

  Widget _buildFilePicker({required String title, String? fileName, required VoidCallback onPressed, required IconData icon, Widget? preview}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: kSecondaryTextColor)),
        const SizedBox(height: 8),
        if (preview != null && fileName != null)
          Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: preview),
          ),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: kSecondaryTextColor),
          label: Text(
            fileName ?? 'Chọn file...',
            style: const TextStyle(color: kSecondaryTextColor),
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kSecondaryTextColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker({required String title, required List<Category> allCategories, required List<int> selectedIds}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: kSecondaryTextColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Xóa bỏ loading indicator vì không cần nữa
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: allCategories.map((category) {
            final isSelected = selectedIds.contains(category.id);
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedIds.add(category.id);
                  } else {
                    selectedIds.remove(category.id);
                  }
                });
              },
              backgroundColor: kCardBackgroundColor,
              selectedColor: kAccentColor,
              checkmarkColor: kPrimaryTextColor,
              labelStyle: TextStyle(color: isSelected ? kPrimaryTextColor : kSecondaryTextColor),
            );
          }).toList(),
        ),
      ],
    );
  }
}

