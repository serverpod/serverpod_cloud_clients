class ServerpodCloudSettingsData {
  bool? enableAnalytics;
  String? outputFormat;

  /// Creates a new instance with all fields set to `null` (unset).
  ServerpodCloudSettingsData();

  ServerpodCloudSettingsData._(this.enableAnalytics, this.outputFormat);

  factory ServerpodCloudSettingsData.fromJson(final Map<String, dynamic> json) {
    return ServerpodCloudSettingsData._(
      json['command_usage_analytics'] as bool?,
      json['output_format'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'command_usage_analytics': enableAnalytics,
    'output_format': outputFormat,
  };

  @override
  String toString() =>
      'ScloudSettings(enableAnalytics: $enableAnalytics, outputFormat: $outputFormat)';
}
