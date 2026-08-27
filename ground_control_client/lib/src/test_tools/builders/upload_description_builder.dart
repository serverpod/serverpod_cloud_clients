import 'dart:convert';

class UploadDescriptionBuilder {
  String _type;
  String _url;
  String _httpMethod;
  Map<String, String> _headers;

  UploadDescriptionBuilder()
    : _type = 'binary',
      _url = 'https://signed.example/file',
      _httpMethod = 'PUT',
      _headers = const {'Content-Type': 'application/octet-stream'};

  UploadDescriptionBuilder withType(final String type) {
    _type = type;

    return this;
  }

  UploadDescriptionBuilder withUrl(final String url) {
    _url = url;

    return this;
  }

  UploadDescriptionBuilder withHttpMethod(final String httpMethod) {
    _httpMethod = httpMethod;

    return this;
  }

  UploadDescriptionBuilder withHeaders(final Map<String, String> headers) {
    _headers = headers;

    return this;
  }

  String build() {
    return jsonEncode({
      'type': _type,
      'url': _url,
      'httpMethod': _httpMethod,
      'headers': _headers,
    });
  }
}
