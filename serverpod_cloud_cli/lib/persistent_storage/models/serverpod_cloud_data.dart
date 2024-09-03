class ServerpodCloudData {
  late final String token;

  ServerpodCloudData(this.token);

  factory ServerpodCloudData.fromJson(final Map<String, dynamic> json) {
    return ServerpodCloudData(json['token'] as String);
  }

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
