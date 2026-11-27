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
    late Future<({String token, String? projectId})?> callbackFuture;

    setUp(() async {
      callbackUrlFuture = Completer<Uri>();
      callbackFuture = ListenerServer.listenForAuthenticationTokenAndProject(
        logger: CommandLogger(VoidLogger()),
        onConnected: (Uri callbackUrl) {
          callbackUrlFuture.complete(callbackUrl);
        },
      );
    });

    group('when a request is made with a token', () {
      late http.Response response;
      setUp(() async {
        final callbackUrl = await callbackUrlFuture.future;
        response = await http.get(
          callbackUrl.replace(queryParameters: {'token': 'myTestToken'}),
        );
      });

      test('then the token is returned without a project id.', () async {
        final callback = await callbackFuture;
        expect(callback, (token: 'myTestToken', projectId: null));
      });

      test('then request response has status code 200.', () {
        expect(response.statusCode, 200);
      });

      test('then response body has successful login message.', () {
        expect(response.body, contains('Login successful'));
      });
    });

    group('when a request is made with a token and a project id', () {
      setUp(() async {
        final callbackUrl = await callbackUrlFuture.future;
        await http.get(
          callbackUrl.replace(
            queryParameters: {'token': 'myTestToken', 'projectId': 'my-app'},
          ),
        );
      });

      test('then the token and the project id are returned.', () async {
        final callback = await callbackFuture;
        expect(callback, (token: 'myTestToken', projectId: 'my-app'));
      });
    });

    group('when a request is made without a token', () {
      late http.Response response;
      setUp(() async {
        final callbackUrl = await callbackUrlFuture.future;
        response = await http.get(
          callbackUrl.replace(queryParameters: {'projectId': 'my-app'}),
        );
      });

      test('then null is returned.', () async {
        final callback = await callbackFuture;
        expect(callback, isNull);
      });

      test('then request response has status code 200.', () {
        expect(response.statusCode, 200);
      });

      test('then response body has failed login message.', () {
        expect(
          response.body,
          contains('Login failed, please try again or contact support.'),
        );
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
          response.headers[HttpHeaders.accessControlAllowOriginHeader],
          '*',
        );
        expect(
          response.headers[HttpHeaders.accessControlAllowMethodsHeader],
          'GET, OPTIONS',
        );
        expect(
          response.headers[HttpHeaders.accessControlAllowHeadersHeader],
          '*',
        );
      });
    });
  });

  group(
    'Given a listener server listening for an authentication token when time limit is reached',
    () {
      late Completer<Uri> callbackUrlFuture;
      late Future<({String token, String? projectId})?> callbackFuture;

      setUp(() async {
        callbackUrlFuture = Completer<Uri>();
        callbackFuture = ListenerServer.listenForAuthenticationTokenAndProject(
          logger: CommandLogger(VoidLogger()),
          onConnected: (Uri callbackUrl) {
            callbackUrlFuture.complete(callbackUrl);
          },
          timeLimit: const Duration(milliseconds: 1),
        );
      });

      test('then null is returned.', () async {
        final callback = await callbackFuture;
        expect(callback, isNull);
      });
    },
  );
}
