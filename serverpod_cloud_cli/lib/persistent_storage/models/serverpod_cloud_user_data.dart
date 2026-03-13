class ServerpodCloudUserData {
  late final String id;

  ServerpodCloudUserData(this.id);

  factory ServerpodCloudUserData.fromJson(final Map<String, dynamic> json) {
    return ServerpodCloudUserData(json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
