/// A field of a customer's billing info that Serverpod Cloud requires before
/// it can invoice the customer.
enum BillingInfoField {
  addressLine1,
  postalCode,
  city,
  country,
  companyName,
  vatNumber,
}

/// Validation of billing info for Serverpod Cloud clients and APIs: the one
/// rule for whether a customer's billing info is complete.
abstract final class BillingInfoValidator {
  /// The required fields that are blank: the address fields for every
  /// customer, plus the company name and VAT number for a business.
  ///
  /// A field is blank when it is null or only whitespace. The list is empty
  /// when the billing info is complete.
  static List<BillingInfoField> missingFields({
    required String? addressLine1,
    required String? postalCode,
    required String? city,
    required String? country,
    required bool isBusiness,
    String? companyName,
    String? vatNumber,
  }) {
    return [
      if (isBlank(addressLine1)) BillingInfoField.addressLine1,
      if (isBlank(postalCode)) BillingInfoField.postalCode,
      if (isBlank(city)) BillingInfoField.city,
      if (isBlank(country)) BillingInfoField.country,
      if (isBusiness && isBlank(companyName)) BillingInfoField.companyName,
      if (isBusiness && isBlank(vatNumber)) BillingInfoField.vatNumber,
    ];
  }

  /// Whether no required field is blank, as in [missingFields].
  static bool isComplete({
    required String? addressLine1,
    required String? postalCode,
    required String? city,
    required String? country,
    required bool isBusiness,
    String? companyName,
    String? vatNumber,
  }) {
    return missingFields(
      addressLine1: addressLine1,
      postalCode: postalCode,
      city: city,
      country: country,
      isBusiness: isBusiness,
      companyName: companyName,
      vatNumber: vatNumber,
    ).isEmpty;
  }

  /// Whether [value] is missing: null or only whitespace. The blank test
  /// every required field is held to.
  static bool isBlank(String? value) => value == null || value.trim().isEmpty;
}
