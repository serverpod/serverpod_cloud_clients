class ServerpodCloudUserData {
  late final String id;

  final String? userAuthId;

  ServerpodCloudUserData(this.id, {this.userAuthId});

  factory ServerpodCloudUserData.fromJson(Map<String, dynamic> json) {
    return ServerpodCloudUserData(
      json['id'] as String,
      userAuthId: switch (json['userAuthId']) {
        final String userAuthId => userAuthId,
        _ => null,
      },
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'userAuthId': ?userAuthId};
}
