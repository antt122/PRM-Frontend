import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class PodcastUploadScreen extends StatefulWidget {
  const PodcastUploadScreen({super.key});

  @override
  State<PodcastUploadScreen> createState() => _PodcastUploadScreenState();
}

class _PodcastUploadScreenState extends State<PodcastUploadScreen> {
  // 1. Thêm controllers cho tất cả các trường
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seriesNameController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _episodeNumberController = TextEditingController();
  final _topicCategoriesController = TextEditingController();
  final _hostNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _emotionCategoriesController = TextEditingController();
  final _tagsController = TextEditingController();
  final _transcriptUrlController = TextEditingController();

  final ApiService _apiService = ApiService();

  XFile? _thumbnailFile;
  File? _audioFile;
  bool _isLoading = false;

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _thumbnailFile = image;
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadPodcast() async {
    // Kiểm tra các trường bắt buộc
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _thumbnailFile == null ||
        _audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiêu đề, Mô tả, và các files không được để trống')),
      );
      return;
    }

    // Chuyển đổi các trường số một cách an toàn
    final episodeNumber = int.tryParse(_episodeNumberController.text);
    final topicCategories = int.tryParse(_topicCategoriesController.text);
    final duration = int.tryParse(_durationController.text);
    final emotionCategories = int.tryParse(_emotionCategoriesController.text);

    if (episodeNumber == null || topicCategories == null || duration == null || emotionCategories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đúng định dạng số cho các trường yêu cầu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // !!! THAY THẾ BẰNG TOKEN THẬT CỦA BẠN !!!
      const String fakeAuthToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";

      // 3. Truyền tất cả dữ liệu từ controller vào service
      final response = await _apiService.createPodcast(
        authToken: fakeAuthToken,
        title: _titleController.text,
        description: _descriptionController.text,
        thumbnailFile: _thumbnailFile!,
        audioFilePath: _audioFile!.path,
        audioFileName: _audioFile!.path.split('/').last,
        seriesName: _seriesNameController.text,
        guestName: _guestNameController.text,
        episodeNumber: episodeNumber,
        topicCategories: topicCategories,
        hostName: _hostNameController.text,
        duration: duration,
        emotionCategories: emotionCategories,
        tags: _tagsController.text,
        transcriptUrl: _transcriptUrlController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo podcast thành công! ID: ${response.id}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Nhớ dispose tất cả controller để tránh rò rỉ bộ nhớ
    _titleController.dispose();
    _descriptionController.dispose();
    _seriesNameController.dispose();
    _guestNameController.dispose();
    _episodeNumberController.dispose();
    _topicCategoriesController.dispose();
    _hostNameController.dispose();
    _durationController.dispose();
    _emotionCategoriesController.dispose();
    _tagsController.dispose();
    _transcriptUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Podcast Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 2. Thêm các TextField vào giao diện
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tiêu đề (bắt buộc)')),
            const SizedBox(height: 16),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Mô tả (bắt buộc)')),
            const SizedBox(height: 16),
            TextField(controller: _seriesNameController, decoration: const InputDecoration(labelText: 'Tên Series')),
            const SizedBox(height: 16),
            TextField(controller: _guestNameController, decoration: const InputDecoration(labelText: 'Tên khách mời')),
            const SizedBox(height: 16),
            TextField(controller: _hostNameController, decoration: const InputDecoration(labelText: 'Tên Host')),
            const SizedBox(height: 16),
            TextField(
              controller: _episodeNumberController,
              decoration: const InputDecoration(labelText: 'Số tập (VD: 10)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Thời lượng (giây, VD: 1800)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicCategoriesController,
              decoration: const InputDecoration(labelText: 'Danh mục chủ đề (ID, VD: 3)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emotionCategoriesController,
              decoration: const InputDecoration(labelText: 'Danh mục cảm xúc (ID, VD: 2)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(controller: _tagsController, decoration: const InputDecoration(labelText: 'Tags (cách nhau bởi dấu phẩy)')),
            const SizedBox(height: 16),
            TextField(controller: _transcriptUrlController, decoration: const InputDecoration(labelText: 'URL của Transcript')),
            const SizedBox(height: 24),

            // Các nút chọn file
            Row(
              children: [
                ElevatedButton.icon(onPressed: _pickThumbnail, icon: const Icon(Icons.image), label: const Text('Chọn Thumbnail')),
                const SizedBox(width: 10),
                Expanded(child: Text(_thumbnailFile?.name ?? 'Chưa chọn ảnh', overflow: TextOverflow.ellipsis)),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(onPressed: _pickAudio, icon: const Icon(Icons.audio_file), label: const Text('Chọn File Âm Thanh')),
                const SizedBox(width: 10),
                Expanded(child: Text(_audioFile?.path.split('/').last ?? 'Chưa chọn audio', overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 32),

            // Nút Upload
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _uploadPodcast,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Đăng Tải'),
            ),
          ],
        ),
      ),
    );
  }
}