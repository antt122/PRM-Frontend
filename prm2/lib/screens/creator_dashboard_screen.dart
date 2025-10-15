import 'package:flutter/material.dart';
import '../models/api_result.dart';
import '../models/my_post.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'PodcastPlayerScreen.dart';
import 'create_postcard_screen.dart';


class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<ApiResult<List<MyPost>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = ApiService.getMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Trang sáng tạo', style: TextStyle(color: kPrimaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<ApiResult<List<MyPost>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAccentColor));
          }
          if (!snapshot.hasData || !snapshot.data!.isSuccess) {
            return Center(
              child: Text(
                'Lỗi tải bài đăng: ${snapshot.data?.message ?? "Vui lòng thử lại."}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kSecondaryTextColor),
              ),
            );
          }
          final posts = snapshot.data!.data ?? [];
          if (posts.isEmpty) {
            return const Center(
                child: Text('Bạn chưa có bài đăng nào.\nHãy tạo postcard đầu tiên!',
                  style: TextStyle(color: kSecondaryTextColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? didPostSuccessfully = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PodcastUploadScreen()),
          );
          if (didPostSuccessfully == true) {
            _loadPosts();
          }
        },
        backgroundColor: kAccentColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Widget để xây dựng mỗi thẻ postcard
  Widget _buildPostCard(MyPost post) {
    // SỬA LỖI Ở ĐÂY: Thêm sự kiện onTap vào GestureDetector
    return GestureDetector(
      onTap: () {
        // Điều hướng đến màn hình Player với ID của bài đăng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastPlayerScreen(postId: post.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                post.thumbnailUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator(color: kAccentColor)),
                errorBuilder: (context, error, stackTrace) {
                  print("Lỗi tải ảnh: $error");
                  return Container(color: Colors.grey[800], child: const Icon(Icons.music_note, color: kSecondaryTextColor));
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Text(
            'Podcast',
            style: TextStyle(color: kSecondaryTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

