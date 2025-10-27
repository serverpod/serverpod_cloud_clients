class ServerpodCloudAuthData {
  late final String token;

  ServerpodCloudAuthData(this.token);

  factory ServerpodCloudAuthData.fromJson(final Map<String, dynamic> json) {
    return ServerpodCloudAuthData(json['token'] as String);
  }

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
