import 'package:flutter/material.dart';
import '../data/res_data.dart';

class AppColor extends ColorData {
  final Color brand;
  final Color textPrimary;
  final Color textSecondary;
  final Color pageBackground;
  final Color cardBackground;

  AppColor({
    this.brand = const Color(0xFF3D5AFE),
    this.textPrimary = const Color(0xFF1B1B1F),
    this.textSecondary = const Color(0xFF5F5F66),
    this.pageBackground = const Color(0xFFF7F8FA),
    this.cardBackground = const Color(0xFFFFFFFF),
  });
}
