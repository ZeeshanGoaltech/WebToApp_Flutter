import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/modules/home/models/recent_app.dart';

class RecentAppsData {
  RecentAppsData._();

  static const List<RecentApp> apps = [
    RecentApp(
      id: '1',
      name: 'MyShop Pro',
      url: 'myshop.com',
      initial: 'M',
      iconColor: AppColors.homeBuilt,
      status: AppStatus.built,
    ),
    RecentApp(
      id: '2',
      name: 'Portfolio App',
      url: 'portfolio.me',
      initial: 'P',
      iconColor: AppColors.homeOrange,
      status: AppStatus.draft,
    ),
    RecentApp(
      id: '3',
      name: 'Blog Reader',
      url: 'myblog.com',
      initial: 'B',
      iconColor: AppColors.homeAccent,
      status: AppStatus.built,
    ),
  ];
}
