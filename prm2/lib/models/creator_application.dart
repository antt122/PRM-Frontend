// Model cho đơn đăng ký Creator
import 'dart:convert';
import 'package:flutter/material.dart';

class CreatorApplication {
  final String experience;
  final String portfolio;
  final String motivation;
  final Map<String, dynamic> socialMedia; // ĐÃ THAY ĐỔI
  final String additionalInfo;

  // Không cần userId vì nó được lấy qua token

  CreatorApplication({
    required this.experience,
    required this.portfolio,
    required this.motivation,
    required this.socialMedia,
    required this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'experience': experience,
      'portfolio': portfolio,
      'motivation': motivation,
      // Đảm bảo sử dụng snake_case cho API
      'social_media': socialMedia,
      'additional_info': additionalInfo,
    };
  }

  factory CreatorApplication.fromJson(Map<String, dynamic> json) {
    return CreatorApplication(
      experience: json['experience'] ?? '',
      portfolio: json['portfolio'] ?? '',
      motivation: json['motivation'] ?? '',
      socialMedia: (json['social_media'] ?? {}) as Map<String, dynamic>,
      additionalInfo: json['additional_info'] ?? '',
    );
  }
}
