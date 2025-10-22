import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../models/podcast_category.dart';

class PodcastUploadScreen extends StatefulWidget {
  const PodcastUploadScreen({super.key});

  @override
  State<PodcastUploadScreen> createState() => _PodcastUploadScreenState();
}

// Alias cho CreatePodcastScreen
typedef CreatePodcastScreen = PodcastUploadScreen;

class _PodcastUploadScreenState extends State<PodcastUploadScreen> {
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hostNameController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _episodeNumberController = TextEditingController(text: '1');
  final _seriesNameController = TextEditingController();
  final _transcriptUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  final _durationController = TextEditingController(
    text: '0',
  ); // NEW: Duration in seconds

  // File selection - Store PlatformFile to support both web and native
  PlatformFile? _audioFile;
  dynamic _thumbnailFile; // Can be File (mobile) or XFile (web)

  // Categories
  List<EmotionCategory> _selectedEmotions = [];
  List<TopicCategory> _selectedTopics = [];

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hostNameController.dispose();
    _guestNameController.dispose();
    _episodeNumberController.dispose();
    _seriesNameController.dispose();
    _transcriptUrlController.dispose();
    _tagsController.dispose();
    _durationController.dispose(); // NEW
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFile = result.files.single;
      });

      // Auto-detect audio duration
      try {
        print('📁 Audio file selected: ${result.files.single.name}');
        print(
          '   Size: ${(result.files.single.size / (1024 * 1024)).toStringAsFixed(2)} MB',
        );

        // Use just_audio to extract duration
        await _detectAudioDuration(result.files.single);
      } catch (e) {
        print('❌ Error detecting duration: $e');
        _showError('Không thể lấy thời lượng audio. Vui lòng nhập tay.');
      }
    }
  }

  /// Detect audio duration using just_audio (mobile) or Web Audio API (web)
  Future<void> _detectAudioDuration(PlatformFile audioFile) async {
    try {
      print('🎵 Detecting audio duration from ${audioFile.name}...');

      if (kIsWeb) {
        // Web - use Web Audio API
        await _detectDurationWeb(audioFile);
      } else {
        // Mobile/Desktop - use just_audio
        await _detectDurationMobile(audioFile);
      }
    } catch (e) {
      print('❌ Error in _detectAudioDuration wrapper: $e');
      _showDurationInputDialog();
    }
  }

  /// Detect duration on mobile using just_audio
  Future<void> _detectDurationMobile(PlatformFile audioFile) async {
    try {
      if (audioFile.path == null) {
        _showError('Không thể đọc file audio. Vui lòng nhập thời lượng tay.');
        return;
      }

      print('📱 Using just_audio for mobile duration detection...');

      final audioPlayer = AudioPlayer();

      try {
        // Load the audio file
        await audioPlayer.setFilePath(audioFile.path!);

        // Get duration
        final duration = audioPlayer.duration;

        if (duration != null && duration.inSeconds > 0) {
          final durationSeconds = duration.inSeconds;

          setState(() {
            _durationController.text = durationSeconds.toString();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Thời lượng: ${_formatDurationDisplay(durationSeconds)}',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
          print(
            '✅ Duration auto-detected: ${_formatDurationDisplay(durationSeconds)} ($durationSeconds seconds)',
          );
        } else {
          print('⚠️ Duration is 0 or null, prompting user to input');
          _showDurationInputDialog();
        }
      } finally {
        await audioPlayer.dispose();
      }
    } catch (e) {
      print('❌ Error detecting duration on mobile: $e');
      _showDurationInputDialog();
    }
  }

  /// Detect duration on web using Web Audio API
  Future<void> _detectDurationWeb(PlatformFile audioFile) async {
    try {
      if (audioFile.bytes == null) {
        _showError('Không thể đọc file audio. Vui lòng nhập thời lượng tay.');
        return;
      }

      print('🌐 Using Web Audio API for web duration detection...');

      // For web, we'll use just_audio as well since it works on web
      final audioPlayer = AudioPlayer();

      try {
        // Create a temporary blob URL for web
        // Note: This is a simplified approach - in production you might want to use a proper web audio solution
        _showError('Trên web, vui lòng nhập thời lượng audio thủ công.');
        _showDurationInputDialog();
      } finally {
        await audioPlayer.dispose();
      }
    } catch (e) {
      print('❌ Error detecting duration on web: $e');
      _showDurationInputDialog();
    }
  }

  /// Show dialog for user to input audio duration manually (fallback)
  void _showDurationInputDialog() {
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Không thể detect thời lượng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng nhập thời lượng podcast theo cách thủ công (tính bằng giây):',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'VD: 720 (cho 12 phút)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cách tính: phút × 60\nVD: 12 phút = 720 giây',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final duration = int.tryParse(durationController.text);
              if (duration != null && duration > 0) {
                setState(() {
                  _durationController.text = duration.toString();
                });
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Thời lượng: ${_formatDurationDisplay(duration)}',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.orange.shade700,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Vui lòng nhập số giây hợp lệ'),
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Format duration for display (seconds to MM:SS or HH:MM:SS)
  String _formatDurationDisplay(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _thumbnailFile = image; // Store XFile directly, not File(path)
      });
    }
  }

  Future<void> _createPodcast() async {
    // Validate required fields
    if (_titleController.text.isEmpty) {
      _showError('Vui lòng nhập tiêu đề');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showError('Vui lòng nhập mô tả');
      return;
    }

    if (_audioFile == null) {
      _showError('Vui lòng chọn file audio');
      return;
    }

    // Get duration from input field
    int durationSeconds = int.tryParse(_durationController.text) ?? 0;
    if (durationSeconds <= 0) {
      _showError('Vui lòng nhập thời lượng podcast (tính bằng giây)');
      return;
    }

    // Parse episode number
    final episodeNumber = int.tryParse(_episodeNumberController.text) ?? 1;

    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    setState(() {
      _isLoading = true;
    });

    try {
      // Show progress dialog for large files
      if (_audioFile != null && _audioFile!.size > 10 * 1024 * 1024) {
        // > 10MB
        _showUploadProgressDialog();
      }

      final result = await ApiService.createPodcast(
        title: _titleController.text,
        description: _descriptionController.text,
        audioFile: _audioFile!,
        thumbnailFile: _thumbnailFile,
        duration: durationSeconds,
        hostName: _hostNameController.text.isNotEmpty
            ? _hostNameController.text
            : null,
        guestName: _guestNameController.text.isNotEmpty
            ? _guestNameController.text
            : null,
        episodeNumber: episodeNumber,
        seriesName: _seriesNameController.text.isNotEmpty
            ? _seriesNameController.text
            : null,
        tags: tags.isNotEmpty ? tags : null,
        emotionCategories: _selectedEmotions.isNotEmpty
            ? _selectedEmotions
            : null,
        topicCategories: _selectedTopics.isNotEmpty ? _selectedTopics : null,
        transcriptUrl: _transcriptUrlController.text.isNotEmpty
            ? _transcriptUrlController.text
            : null,
      );

      // Close progress dialog if it was shown
      if (_audioFile != null && _audioFile!.size > 10 * 1024 * 1024) {
        Navigator.of(context).pop(); // Close progress dialog
      }

      if (result.isSuccess) {
        _showSuccess('Podcast tạo thành công!');
        // Navigate back
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        }
      } else {
        _showError(result.message ?? 'Lỗi tạo podcast');
      }
    } catch (e) {
      // Close progress dialog if it was shown
      if (_audioFile != null && _audioFile!.size > 10 * 1024 * 1024) {
        Navigator.of(context).pop(); // Close progress dialog
      }
      _showError('Lỗi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show upload progress dialog for large files
  void _showUploadProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📤 Đang upload podcast...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'File size: ${(_audioFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng đợi, không tắt app...',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Timeout: ${((_audioFile!.size / (1024 * 1024)) * 20).ceil().clamp(120, 900)}s',
              style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
            ),
            if (_audioFile!.size > 20 * 1024 * 1024) // > 20MB
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  '⚠️ File lớn, có thể mất vài phút để upload',
                  style: TextStyle(fontSize: 11, color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tạo Podcast Mới',
          style: TextStyle(color: kPrimaryTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio file picker
            _buildFilePickerBox(
              title: 'Chọn File Audio',
              subtitle: _audioFile != null
                  ? _audioFile!.name
                  : 'Chưa chọn file',
              icon: Icons.audio_file,
              onTap: _pickAudioFile,
              isRequired: true,
            ),
            const SizedBox(height: 8),
            // Audio file info
            if (_audioFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📄 ${_audioFile!.name}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kích thước: ${(_audioFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Thời lượng: ${_formatDurationDisplay(int.tryParse(_durationController.text) ?? 0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Thumbnail picker
            _buildFilePickerBox(
              title: 'Chọn Ảnh Đại Diện',
              subtitle: _thumbnailFile != null ? 'Ảnh đã chọn' : 'Tùy chọn',
              icon: Icons.image,
              onTap: _pickThumbnail,
              isRequired: false,
            ),
            if (_thumbnailFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _thumbnailFile is XFile
                        ? Image.network(
                            _thumbnailFile.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                          )
                        : Container(
                            color: Colors.green.shade50,
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Title field
            _buildTextField(
              controller: _titleController,
              label: 'Tiêu Đề',
              hint: 'Nhập tiêu đề podcast',
              isRequired: true,
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            // Description field
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô Tả',
              hint: 'Nhập mô tả chi tiết về podcast',
              isRequired: true,
              maxLength: 2000,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Host name
            _buildTextField(
              controller: _hostNameController,
              label: 'Người Dẫn',
              hint: 'Nhập tên người dẫn chương trình',
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Guest name
            _buildTextField(
              controller: _guestNameController,
              label: 'Khách Mời',
              hint: 'Nhập tên khách mời',
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Episode number
            _buildTextField(
              controller: _episodeNumberController,
              label: 'Số Tập',
              hint: '1',
              keyboardType: TextInputType.number,
              maxLength: 5,
            ),
            const SizedBox(height: 16),

            // Series name
            _buildTextField(
              controller: _seriesNameController,
              label: 'Tên Series',
              hint: 'Nhập tên series (nếu có)',
              maxLength: 200,
            ),
            const SizedBox(height: 16),

            // Tags
            _buildTextField(
              controller: _tagsController,
              label: 'Tags',
              hint: 'Nhập các tags cách nhau bằng dấu phẩy',
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Transcript URL
            _buildTextField(
              controller: _transcriptUrlController,
              label: 'Liên Kết Transcript',
              hint: 'Nhập URL file transcript',
              maxLength: 1000,
            ),
            const SizedBox(height: 24),

            // Emotion categories
            Text(
              'Emotion Categories',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: kPrimaryTextColor),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EmotionCategory.values
                  .where((e) => e != EmotionCategory.none)
                  .map((emotion) {
                    final isSelected = _selectedEmotions.contains(emotion);
                    return FilterChip(
                      label: Text(
                        emotion.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kPrimaryTextColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          if (isSelected) {
                            _selectedEmotions.remove(emotion);
                          } else {
                            _selectedEmotions.add(emotion);
                          }
                        });
                      },
                      backgroundColor: kSurfaceColor.withOpacity(0.3),
                      selectedColor: kAccentColor,
                      side: BorderSide(
                        color: isSelected ? kAccentColor : kGlassBorder,
                        width: 1,
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Topic categories
            Text(
              'Topic Categories',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: kPrimaryTextColor),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TopicCategory.values
                  .where((e) => e != TopicCategory.none)
                  .map((topic) {
                    final isSelected = _selectedTopics.contains(topic);
                    return FilterChip(
                      label: Text(
                        topic.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kPrimaryTextColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          if (isSelected) {
                            _selectedTopics.remove(topic);
                          } else {
                            _selectedTopics.add(topic);
                          }
                        });
                      },
                      backgroundColor: kSurfaceColor.withOpacity(0.3),
                      selectedColor: kAccentColor,
                      side: BorderSide(
                        color: isSelected ? kAccentColor : kGlassBorder,
                        width: 1,
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPodcast,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Tạo Podcast',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLength = 100,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kPrimaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(color: kPrimaryTextColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kPrimaryTextColor.withOpacity(0.5)),
            filled: true,
            fillColor: kHighlightColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: kInputBorderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: kInputBorderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: kAccentColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: kInputBorderColor, width: 1.5),
          borderRadius: BorderRadius.circular(15),
          color: kHighlightColor,
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: kPrimaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRequired)
                        const Text(' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: kPrimaryTextColor.withOpacity(0.6),
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
