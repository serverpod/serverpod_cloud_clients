import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/listener_server.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() async {
  group('Given a listener server listening for an authentication token', () {
    late Completer<Uri> callbackUrlFuture;
    late Future<String?> tokenFuture;

    setUp(() async {
      callbackUrlFuture = Completer<Uri>();
      tokenFuture = ListenerServer.listenForAuthenticationToken(
        logger: CommandLogger(VoidLogger()),
        onConnected: (final Uri callbackUrl) {
          callbackUrlFuture.complete(callbackUrl);
        },
      );
    });

    group(
        'when a request is made with an authentication token parameter then token is returned.',
        () {
      const testToken = 'myTestToken';

      late http.Response response;
      setUp(() async {
        final callbackUrl = await callbackUrlFuture.future;
        final urlWithToken =
            callbackUrl.replace(queryParameters: {'token': testToken});
        response = await http.get(urlWithToken);
      });

      test('then a token is returned.', () async {
        final fetchedToken = await tokenFuture;
        expect(fetchedToken, testToken);
      });

      test('then request response has status code 200.', () {
        expect(response.statusCode, 200);
      });

      test('then response body has successful login message.', () {
        expect(response.body,
            contains('Login successful, you may now close this window.'));
      });
    });

    group(
        'when a request is made without an authentication token parameter then token null is returned.',
        () {
      late http.Response response;
      setUp(() async {
        final callbackUrl = await callbackUrlFuture.future;
        response = await http.get(callbackUrl);
      });

      test('then null is returned.', () async {
        final fetchedToken = await tokenFuture;
        expect(fetchedToken, null);
      });

      test('then request response has status code 200.', () {
        expect(response.statusCode, 200);
      });

      test('then response body has failed login message.', () {
        expect(response.body,
            contains('Login failed, please try again or contact support.'));
      });
    });

    group('when a preflight check request is made', () {
      late http.Response response;

      setUp(() async {
        final callbackUrl = await callbackUrlFuture.future;
        final client = http.Client();
        final request = http.Request('OPTIONS', callbackUrl);
        final streamedResponse = await client.send(request);
        response = await http.Response.fromStream(streamedResponse);
      });

      test('then request response has status code 200.', () {
        expect(response.statusCode, 200);
      });

      test('then the response headers contain expected CORS headers.', () {
        expect(
            response.headers[HttpHeaders.accessControlAllowOriginHeader], '*');
        expect(response.headers[HttpHeaders.accessControlAllowMethodsHeader],
            'GET, OPTIONS');
        expect(
            response.headers[HttpHeaders.accessControlAllowHeadersHeader], '*');
      });
    });
  });

  group(
      'Given a listener server listening for an authentication token when time limit is reached',
      () {
    late Completer<Uri> callbackUrlFuture;
    late Future<String?> tokenFuture;

    setUp(() async {
      callbackUrlFuture = Completer<Uri>();
      tokenFuture = ListenerServer.listenForAuthenticationToken(
        logger: CommandLogger(VoidLogger()),
        onConnected: (final Uri callbackUrl) {
          callbackUrlFuture.complete(callbackUrl);
        },
        timeLimit: const Duration(milliseconds: 1),
      );
    });

    test('then token is null.', () async {
      final fetchedToken = await tokenFuture;
      expect(fetchedToken, isNull);
    });
  });
}
