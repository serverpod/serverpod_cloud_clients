import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given a private customer with a full address', () {
    test('when validating then nothing is missing', () {
      expect(
        BillingInfoValidator.missingFields(
          addressLine1: '123 Main St',
          postalCode: '12345',
          city: 'Springfield',
          country: 'US',
          isBusiness: false,
        ),
        isEmpty,
      );
    });

    test('when the company name is blank then nothing is missing', () {
      expect(
        BillingInfoValidator.isComplete(
          addressLine1: '123 Main St',
          postalCode: '12345',
          city: 'Springfield',
          country: 'US',
          isBusiness: false,
          companyName: null,
        ),
        isTrue,
      );
    });
  });

  group('Given a private customer with only a country', () {
    test('when validating then the address line, postal code and city are'
        ' missing', () {
      expect(
        BillingInfoValidator.missingFields(
          addressLine1: '',
          postalCode: ' ',
          city: null,
          country: 'SE',
          isBusiness: false,
        ),
        [
          BillingInfoField.addressLine1,
          BillingInfoField.postalCode,
          BillingInfoField.city,
        ],
      );
    });
  });

  group('Given a business customer with a full address', () {
    test('when the company name is set then nothing is missing', () {
      expect(
        BillingInfoValidator.missingFields(
          addressLine1: '123 Main St',
          postalCode: '12345',
          city: 'Springfield',
          country: 'US',
          isBusiness: true,
          companyName: 'Acme Inc',
        ),
        isEmpty,
      );
    });

    test('when the company name is blank then it is missing', () {
      expect(
        BillingInfoValidator.missingFields(
          addressLine1: '123 Main St',
          postalCode: '12345',
          city: 'Springfield',
          country: 'US',
          isBusiness: true,
          companyName: ' ',
        ),
        [BillingInfoField.companyName],
      );
    });
  });

  group('Given a customer with no country', () {
    test('when validating then the country is missing', () {
      expect(
        BillingInfoValidator.missingFields(
          addressLine1: '123 Main St',
          postalCode: '12345',
          city: 'Springfield',
          country: '',
          isBusiness: false,
        ),
        [BillingInfoField.country],
      );
    });
  });
}
