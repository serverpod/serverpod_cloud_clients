import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain/custom_domain_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a CustomDomainAttachTextUi', () {
    group('when rendered after attaching a domain', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const CustomDomainAttachTextUi(baseCommand: 'scloud'),
          data: {
            'domainName': 'example.com',
            'projectId': 'my-project',
            'records': [
              {
                'type': 'CNAME',
                'domain': 'example.com',
                'value': 'my-project.serverpod.space',
              },
            ],
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the attach success message', () {
        expect(stdout, contains('Custom domain attached successfully!'));
      });

      test('then stdout contains the DNS record table', () {
        expect(stdout, contains('Record type'));
        expect(stdout, contains('CNAME'));
        expect(stdout, contains('example.com'));
        expect(stdout, contains('my-project.serverpod.space'));
      });

      test('then stdout hints to list and verify the domain', () {
        expect(stdout, contains('scloud domain list --project my-project'));
        expect(
          stdout,
          contains('scloud domain verify example.com --project my-project'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a CustomDomainListTextUi', () {
    group('when rendered with default and custom domains', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const CustomDomainListTextUi(),
          data: CustomDomainNameList(
            customDomainNames: [
              CustomDomainName(
                capsuleId: 1,
                name: 'api.example.com',
                status: DomainNameStatus.configured,
                target: DomainNameTarget.api,
                dnsRecordVerificationValue: 'my-project.api.serverpod.space',
                dnsRecordType: DnsRecordType.cname,
              ),
            ],
            defaultDomainsByTarget: {
              DomainNameTarget.api: 'my-project.api.serverpod.space',
            },
          ),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the default domain heading', () {
        expect(stdout, contains('Default domain name'));
      });

      test('then stdout contains the custom domain heading', () {
        expect(stdout, contains('Custom domain name'));
      });

      test('then stdout contains the default domain', () {
        expect(stdout, contains('my-project.api.serverpod.space'));
      });

      test('then stdout contains the custom domain and status', () {
        expect(
          stdout,
          stringContainsInOrder(['api.example.com', 'api', 'Configured']),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a CustomDomainDetachTextUi', () {
    group('when rendered after detaching a domain', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const CustomDomainDetachTextUi(),
          data: const {'domainName': 'example.com'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the detach success message', () {
        expect(
          stdout,
          contains('Successfully detached custom domain: example.com.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a CustomDomainVerifyTextUi', () {
    group('when rendered with a configured domain', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const CustomDomainVerifyTextUi(),
          data: DomainNameStatus.configured,
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that the domain is active', () {
        expect(
          stdout,
          contains(
            'Successfully verified the DNS record for the custom domain. It is now active.',
          ),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a domain that needs setup', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const CustomDomainVerifyTextUi(),
          data: DomainNameStatus.needsSetup,
        );
        stdout = io.stdout;
      });

      test('then stdout reports that verification failed', () {
        expect(
          stdout,
          contains('Failed to verify the DNS record for the custom domain.'),
        );
      });
    });

    group('when rendered with a pending domain', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const CustomDomainVerifyTextUi(),
          data: DomainNameStatus.pending,
        );
        stdout = io.stdout;
      });

      test('then stdout reports that certificate creation is pending', () {
        expect(
          stdout,
          stringContainsInOrder(['certificate creation is', 'still pending']),
        );
      });
    });
  });
}
