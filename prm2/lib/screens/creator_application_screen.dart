// Màn hình đăng ký trở thành Creator (PHIÊN BẢN LIQUID GLASS)
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/api_result.dart';
import '../models/creator_application.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import '../components/custom_text_field.dart';

class CreatorApplicationScreen extends StatefulWidget {
  const CreatorApplicationScreen({super.key});

  @override
  State<CreatorApplicationScreen> createState() =>
      _CreatorApplicationScreenState();
}

class _CreatorApplicationScreenState extends State<CreatorApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers cho các trường input
  final _experienceController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _motivationController = TextEditingController();

  // Controllers cho các kênh mạng xã hội cụ thể (Khớp với Map)
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();

  final _additionalInfoController = TextEditingController();

  @override
  void dispose() {
    _experienceController.dispose();
    _portfolioController.dispose();
    _motivationController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    // 1. Kiểm tra tính hợp lệ của form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // 2. Tạo đối tượng application từ dữ liệu form
    // Xử lý social media thành Map<String, dynamic> theo yêu cầu API
    final socialMediaMap = {
      // Chỉ thêm vào map nếu controller có giá trị
      if (_facebookController.text.isNotEmpty)
        'facebook': _facebookController.text,
      if (_instagramController.text.isNotEmpty)
        'instagram': _instagramController.text,
      if (_tiktokController.text.isNotEmpty) 'tiktok': _tiktokController.text,
    };

    // Kiểm tra nếu map rỗng, có thể gửi rỗng hoặc không gửi tùy theo API
    // Ở đây ta gửi map rỗng nếu không có dữ liệu
    if (socialMediaMap.isEmpty) {
      socialMediaMap['main'] =
          _portfolioController.text; // Dùng portfolio làm link chính nếu trống
    }

    final application = CreatorApplication(
      experience: _experienceController.text,
      portfolio: _portfolioController.text,
      motivation: _motivationController.text,
      socialMedia: socialMediaMap, // Dùng Map đã tạo
      additionalInfo: _additionalInfoController.text,
    );

    // 3. Gọi API
    final ApiResult<dynamic> result = await ApiService.submitCreatorApplication(
      application,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    // 4. Hiển thị kết quả
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message ??
              (result.isSuccess
                  ? 'Gửi đơn đăng ký thành công!'
                  : 'Đã có lỗi xảy ra.'),
          style: AppFonts.body.copyWith(color: kPrimaryTextColor),
        ),
        backgroundColor: result.isSuccess ? kSuccessColor : kErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Nếu thành công, quay về màn hình trước đó
    if (result.isSuccess) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: Text(
            'Trở thành Creator',
            style: AppFonts.title2.copyWith(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundColor, kSurfaceColor],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: kGlassBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGlassBorder, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: kGlassShadow,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chia sẻ câu chuyện của bạn',
                            style: AppFonts.title1.copyWith(
                              color: kPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Hãy cho chúng tôi biết thêm về hành trình và nguồn cảm hứng của bạn. Chúng tôi rất mong được lắng nghe!',
                            style: AppFonts.body.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // --- Các trường nhập liệu chính ---
                          CustomTextField(
                            controller: _experienceController,
                            label: 'Kinh nghiệm của bạn',
                            hint:
                                'Bạn đã có kinh nghiệm sáng tạo nội dung chưa?...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _portfolioController,
                            label: 'Portfolio hoặc sản phẩm nổi bật',
                            hint: 'Link đến blog, kênh YouTube, podcast...',
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _motivationController,
                            label: 'Động lực của bạn là gì?',
                            hint:
                                'Điều gì truyền cảm hứng cho bạn để tạo ra nội dung?...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 40),

                          // --- Tiêu đề Social Media ---
                          Text(
                            'Mạng xã hội (Các kênh chính)',
                            style: AppFonts.title3.copyWith(
                              color: kPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // --- Các trường nhập liệu Social Media (Map) ---
                          CustomTextField(
                            controller: _facebookController,
                            label: 'Facebook Link',
                            hint: 'https://facebook.com/...',
                            isRequired: false,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _instagramController,
                            label: 'Instagram Link',
                            hint: 'https://instagram.com/...',
                            isRequired: false,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _tiktokController,
                            label: 'TikTok Link',
                            hint: 'https://tiktok.com/@...',
                            isRequired: false,
                          ),

                          const SizedBox(height: 40),

                          // --- Thông tin bổ sung ---
                          CustomTextField(
                            controller: _additionalInfoController,
                            label: 'Thông tin bổ sung',
                            hint: 'Bạn còn muốn chia sẻ điều gì thêm không?',
                            isRequired: false,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 40),

                          // --- Nút Gửi với Liquid Glass ---
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kAccentColor,
                                      kAccentColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kAccentColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _submitApplication,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Text(
                                          'GỬI ĐƠN ĐĂNG KÝ',
                                          style: AppFonts.headline.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
