import 'package:web_to_app/data/models/app_models.dart';
import 'package:web_to_app/data/models/build_models.dart';

enum ProjectDisplayStatus {
  draft,
  building,
  built,
  buildFailed,
  canceled,
}

class AppBuildSnapshot {
  const AppBuildSnapshot({this.latest, this.latestSuccess});

  final BuildDto? latest;
  final BuildDto? latestSuccess;

  factory AppBuildSnapshot.fromBuilds(List<BuildDto> builds) {
    if (builds.isEmpty) return const AppBuildSnapshot();

    final sorted = List<BuildDto>.from(builds)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    BuildDto? latestSuccess;
    for (final build in sorted) {
      if (build.isSuccess) {
        latestSuccess = build;
        break;
      }
    }

    return AppBuildSnapshot(latest: sorted.first, latestSuccess: latestSuccess);
  }

  bool get hasActiveBuild => latest != null && !latest!.isTerminal;
}

class ProjectStatusResolver {
  ProjectStatusResolver._();

  static ProjectDisplayStatus resolve({
    required AppSummary summary,
    AppBuildSnapshot snapshot = const AppBuildSnapshot(),
  }) {
    final latest = snapshot.latest;
    final latestSuccess = snapshot.latestSuccess;
    final hasSuccessfulBuild = latestSuccess != null;

    if (latest != null && !latest.isTerminal) {
      return ProjectDisplayStatus.building;
    }

    if (latest != null) {
      switch (latest.status) {
        case 'failed':
          return hasSuccessfulBuild
              ? ProjectDisplayStatus.built
              : ProjectDisplayStatus.buildFailed;
        case 'canceled':
        case 'cancelled':
          return hasSuccessfulBuild
              ? ProjectDisplayStatus.built
              : ProjectDisplayStatus.canceled;
        case 'succeeded':
          return ProjectDisplayStatus.built;
      }
    }

    if (hasSuccessfulBuild || (summary.currentVersionCode ?? 0) > 0) {
      return ProjectDisplayStatus.built;
    }

    return ProjectDisplayStatus.draft;
  }

  static String buildingDetailLabel(String? buildStatus) {
    return switch (buildStatus) {
      'queued' || 'claimed' => 'build_queued',
      'uploading' => 'build_uploading',
      'building' => 'project_status_building',
      _ => 'project_status_building',
    };
  }
}
