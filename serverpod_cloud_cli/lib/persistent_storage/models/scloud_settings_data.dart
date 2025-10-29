class ServerpodCloudSettingsData {
  bool? enableAnalytics;

  /// Creates a new instance with all fields set to `null` (unset).
  ServerpodCloudSettingsData();

  ServerpodCloudSettingsData._(this.enableAnalytics);

  factory ServerpodCloudSettingsData.fromJson(
    final Map<String, dynamic> json,
  ) {
    return ServerpodCloudSettingsData._(
      json['enable_analytics'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'enable_analytics': enableAnalytics,
      };

  @override
  String toString() => 'ScloudSettings(enableAnalytics: $enableAnalytics)';
}
