import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';

void main() {
  test(
      'Given a pubspec with a serverpod dependency, when the isServerpodServer method is called, then the result is true',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^2.3.0
'''));

    final result = pubspec.isServerpodServer();
    expect(result, isTrue);
  });

  test(
      'Given a pubspec without a serverpod dependency, when the isServerpodServer method is called, then the result is false',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
'''));

    final result = pubspec.isServerpodServer();
    expect(result, isFalse);
  });

  test(
      'Given a pubspec without a sdk constraint, when the projectDependencyIssues method is called, then the result contains the sdk error',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
dependencies:
  serverpod: ^2.3.0
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, contains('No sdk constraint found in pubspec.yaml'));
  });

  test(
      'Given a pubspec with a serverpod dependency and a too advanced sdk version, when the projectDependencyIssues method is called, then the result contains the sdk error',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.8.0 <4.0.0'
dependencies:
  serverpod: ^2.3.0
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, isNotEmpty);
    expect(result.first, contains('Unsupported sdk version constraint'));
  });

  test(
      'Given a pubspec with a serverpod dependency and a too old sdk version, when the projectDependencyIssues method is called, then the result contains the sdk error',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.1.0 <3.2.0'
dependencies:
  serverpod: ^2.3.0
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, isNotEmpty);
    expect(result.first, contains('Unsupported sdk version constraint'));
  });

  test(
      'Given a pubspec with a serverpod dependency and a too old serverpod version, when the projectDependencyIssues method is called, then the result contains the serverpod error',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^2.2.0
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, isNotEmpty);
    expect(result.first, contains('Unsupported serverpod version constraint'));
  });

  test(
      'Given a pubspec with a serverpod dependency and a compatible sdk version, when the projectDependencyIssues method is called, then the result is empty',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^2.3.0
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, isEmpty);
  });

  test(
      'Given a pubspec with a serverpod dependency and a compatible sdk version, when the projectDependencyIssues method is called, then the result is empty',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, contains('No serverpod dependency found in pubspec.yaml'));
  });

  test(
      'Given a pubspec without serverpod dependency, when the projectDependencyIssues method is called, then the result contains the serverpod error',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
'''));

    final result = pubspec.projectDependencyIssues();
    expect(result, contains('No serverpod dependency found in pubspec.yaml'));
  });

  test(
      'Given a pubspec without serverpod dependency and without sdk constraint, when the projectDependencyIssues method is called, then the result contains both errors',
      () {
    final pubspec = TenantProjectPubspec(Pubspec.parse('''
name: my_project
environment:
dependencies:
'''));

    final result = pubspec.projectDependencyIssues();
    expect(
        result,
        allOf([
          contains('No serverpod dependency found in pubspec.yaml'),
          contains('No sdk constraint found in pubspec.yaml'),
        ]));
  });
}
