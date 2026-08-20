import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/data/models/app_models.dart';

enum AppStatus { built, draft }

class RecentApp {
  const RecentApp({
    required this.id,
    required this.name,
    required this.url,
    required this.initial,
    required this.iconColor,
    required this.status,
  });

  final String id;
  final String name;
  final String url;
  final String initial;
  final Color iconColor;
  final AppStatus status;

  factory RecentApp.fromSummary(AppSummary summary) {
    final built = (summary.currentVersionCode ?? 0) > 0;
    return RecentApp(
      id: summary.id,
      name: summary.name,
      url: summary.androidPackage,
      initial: summary.initial,
      iconColor: built ? AppColors.homeBuilt : AppColors.homeAccent,
      status: built ? AppStatus.built : AppStatus.draft,
    );
  }
}
