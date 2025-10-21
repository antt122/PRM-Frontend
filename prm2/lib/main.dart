
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm2/screens/LoginScreen.dart';
import 'package:prm2/utils/AppTheme.dart';


Future<void> main() async {
  // Đảm bảo các binding được khởi tạo trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized();
  // Tải các biến môi trường từ file .env
  await dotenv.load(fileName: ".env");

  runApp(
    // Bọc toàn bộ ứng dụng trong ProviderScope để Riverpod hoạt động
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard', // Đặt tên phù hợp cho ứng dụng quản lý
      debugShowCheckedModeBanner: false,
      // Sử dụng theme đã được định nghĩa
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Mặc định là theme tối
      // Màn hình khởi đầu là LoginScreen
      home: const LoginScreen(),
    );
  }
}

