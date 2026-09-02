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

  AuthTokenInfoBuilder withTokenId(String tokenId) {
    _tokenId = tokenId;
    return this;
  }

  AuthTokenInfoBuilder withIssuer(String issuer) {
    _issuer = issuer;
    return this;
  }

  AuthTokenInfoBuilder withMethod(String method) {
    _method = method;
    return this;
  }

  AuthTokenInfoBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  AuthTokenInfoBuilder withExpiresAt(DateTime? expiresAt) {
    _expiresAt = expiresAt;
    return this;
  }

  AuthTokenInfoBuilder withExpireAfterUnusedFor(
    Duration? expireAfterUnusedFor,
  ) {
    this.expireAfterUnusedFor = expireAfterUnusedFor;
    return this;
  }

  AuthTokenInfoBuilder withPersonalAccessToken() {
    _issuer = 'session';
    _method = 'PAT';
    return this;
  }

  AuthTokenInfoBuilder withServerSideSession() {
    _issuer = 'session';
    _method = 'email';
    return this;
  }

  AuthTokenInfoBuilder withJwtSession() {
    _issuer = 'jwt';
    _method = 'email';
    return this;
  }

  AuthTokenInfoBuilder withLastUsedAt(DateTime? lastUsedAt) {
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
