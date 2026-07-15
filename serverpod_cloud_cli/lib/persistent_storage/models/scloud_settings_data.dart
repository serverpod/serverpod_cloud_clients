class ServerpodCloudSettingsData {
  bool? enableAnalytics;
  String? projectContext;

  /// Creates a new instance with all fields set to `null` (unset).
  ServerpodCloudSettingsData();

  ServerpodCloudSettingsData._(this.enableAnalytics, this.projectContext);

  factory ServerpodCloudSettingsData.fromJson(final Map<String, dynamic> json) {
    return ServerpodCloudSettingsData._(
      json['command_usage_analytics'] as bool?,
      json['project_context'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'command_usage_analytics': enableAnalytics,
    'project_context': projectContext,
  };

  @override
  String toString() =>
      'ScloudSettings('
      'enableAnalytics: $enableAnalytics, '
      'projectContext: $projectContext)';
}
