import 'package:ground_control_client/ground_control_client.dart';

import 'app_build_summary_builder.dart';
import 'app_platform_info_builder.dart';

/// Builds an [AppPublishingInfo]. The default is a capsule that has never
/// set up app publishing: both platforms turned off and empty.
class AppPublishingInfoBuilder {
  List<AppPlatformInfo> _platforms;

  AppPublishingInfoBuilder()
    : _platforms = [
        AppPlatformInfoBuilder().build(),
        AppPlatformInfoBuilder().withPlatform(AppPlatform.android).build(),
      ];

  AppPublishingInfoBuilder withIosPublished() {
    _platforms = [
      AppPlatformInfoBuilder()
          .withIosReady()
          .withLatestBuild(AppBuildSummaryBuilder().build())
          .build(),
      AppPlatformInfoBuilder().withPlatform(AppPlatform.android).build(),
    ];
    return this;
  }

  AppPublishingInfoBuilder withBothPublished() {
    _platforms = [
      AppPlatformInfoBuilder()
          .withIosReady()
          .withLatestBuild(AppBuildSummaryBuilder().build())
          .build(),
      AppPlatformInfoBuilder()
          .withAndroidReady()
          .withLatestBuild(
            AppBuildSummaryBuilder().withPlatform(AppPlatform.android).build(),
          )
          .build(),
    ];
    return this;
  }

  AppPublishingInfoBuilder withPlatforms(List<AppPlatformInfo> platforms) {
    _platforms = platforms;
    return this;
  }

  AppPublishingInfo build() {
    return AppPublishingInfo(platforms: _platforms);
  }
}
