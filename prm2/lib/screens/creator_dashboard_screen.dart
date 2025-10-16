import 'package:flutter/material.dart';
import '../models/api_result.dart';
import '../models/my_post.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'create_postcard_screen.dart'; // Import màn hình tạo mới

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
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
        title:
        const Text('Trang sáng tạo', style: TextStyle(color: kPrimaryTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: FutureBuilder<ApiResult<List<MyPost>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryTextColor));
          }
          if (!snapshot.hasData || !snapshot.data!.isSuccess) {
            return Center(
              child: Text(
                'Lỗi tải bài đăng: ${snapshot.data?.message ?? "Vui lòng thử lại."}',
                textAlign: TextAlign.center,
              ),
            );
          }
          final posts = snapshot.data!.data ?? [];
          if (posts.isEmpty) {
            return const Center(
                child: Text('Bạn chưa có bài đăng nào.\nHãy tạo postcard đầu tiên!'));
          }

          // Hiển thị dưới dạng GridView
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cột
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2 / 3, // Tỉ lệ ảnh
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
          // Mở màn hình tạo mới và chờ kết quả
          final bool? didPost = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PodcastUploadScreen(),
            ),
          );
          // Nếu người dùng đã đăng bài thành công, tải lại danh sách
          if (didPost == true) {
            _loadPosts();
          }
        },
        backgroundColor: kAccentColor,
        child: const Icon(Icons.add, color: kPrimaryTextColor),
      ),
    );
  }

  Widget _buildPostCard(MyPost post) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          title: Text(post.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(post.description
              , maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        child: Image.network(
          post.thumbnailUrl,
          fit: BoxFit.cover,
          // Placeholder và xử lý lỗi cho ảnh
          loadingBuilder: (context, child, progress) {
            return progress == null ? child : const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
        ),
      ),
    );
  }
}
