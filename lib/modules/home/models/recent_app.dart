import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/data/models/app_models.dart';
import 'package:web_to_app/modules/home/models/project_display_status.dart';

class RecentApp {
  const RecentApp({
    required this.id,
    required this.name,
    required this.url,
    required this.initial,
    required this.iconColor,
    required this.status,
    this.buildStatus,
  });

  final String id;
  final String name;
  final String url;
  final String initial;
  final Color iconColor;
  final ProjectDisplayStatus status;
  final String? buildStatus;

  factory RecentApp.fromSummary(
    AppSummary summary, {
    AppBuildSnapshot snapshot = const AppBuildSnapshot(),
  }) {
    final status = ProjectStatusResolver.resolve(
      summary: summary,
      snapshot: snapshot,
    );

    return RecentApp(
      id: summary.id,
      name: summary.name,
      url: summary.androidPackage,
      initial: summary.initial,
      iconColor: _iconColorFor(status),
      status: status,
      buildStatus: snapshot.latest?.status,
    );
  }

  static Color _iconColorFor(ProjectDisplayStatus status) {
    return switch (status) {
      ProjectDisplayStatus.built => AppColors.homeBuilt,
      ProjectDisplayStatus.buildFailed => AppColors.homeFailed,
      ProjectDisplayStatus.building => AppColors.homeAccent,
      ProjectDisplayStatus.canceled => AppColors.homeMuted,
      ProjectDisplayStatus.draft => AppColors.homeAccent,
    };
  }
}
