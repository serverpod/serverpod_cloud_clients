class ServerpodCloudSettingsData {
  bool? enableAnalytics;

  /// Creates a new instance with all fields set to `null` (unset).
  ServerpodCloudSettingsData();

  ServerpodCloudSettingsData._(this.enableAnalytics);

  factory ServerpodCloudSettingsData.fromJson(final Map<String, dynamic> json) {
    return ServerpodCloudSettingsData._(
      json['command_usage_analytics'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {'command_usage_analytics': enableAnalytics};

  @override
  String toString() => 'ScloudSettings(enableAnalytics: $enableAnalytics)';
}
