import 'package:ground_control_client/ground_control_client.dart';

class AuthTokenInfoBuilder {
  String _tokenId;
  String _issuer;
  String _method;
  DateTime _createdAt;
  DateTime? _expiresAt;
  Duration? expireAfterUnusedFor;
  DateTime? lastUsedAt;

  AuthTokenInfoBuilder()
    : _tokenId = 'test-token-id',
      _issuer = 'test-auth-issuer',
      _method = 'email',
      _createdAt = DateTime.now(),
      _expiresAt = null,
      expireAfterUnusedFor = null,
      lastUsedAt = null;

  AuthTokenInfoBuilder withTokenId(final String tokenId) {
    _tokenId = tokenId;
    return this;
  }

  AuthTokenInfoBuilder withIssuer(final String issuer) {
    _issuer = issuer;
    return this;
  }

  AuthTokenInfoBuilder withMethod(final String method) {
    _method = method;
    return this;
  }

  AuthTokenInfoBuilder withCreatedAt(final DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  AuthTokenInfoBuilder withExpiresAt(final DateTime? expiresAt) {
    _expiresAt = expiresAt;
    return this;
  }

  AuthTokenInfoBuilder withExpireAfterUnusedFor(
    final Duration? expireAfterUnusedFor,
  ) {
    this.expireAfterUnusedFor = expireAfterUnusedFor;
    return this;
  }

  AuthTokenInfoBuilder withLastUsedAt(final DateTime? lastUsedAt) {
    this.lastUsedAt = lastUsedAt;
    return this;
  }

  AuthTokenInfo build() {
    return AuthTokenInfo(
      tokenId: _tokenId,
      issuer: _issuer,
      method: _method,
      createdAt: _createdAt,
      expiresAt: _expiresAt,
      expireAfterUnusedFor: expireAfterUnusedFor,
      lastUsedAt: lastUsedAt,
    );
  }
}
