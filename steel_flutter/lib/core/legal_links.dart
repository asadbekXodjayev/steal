/// Canonical hosted legal + contact endpoints used by the in-app legal screen,
/// the registration consent, and the account-deletion flow.
///
/// ⚠️ REPLACE these placeholders with your real values before publishing to
/// Google Play. The Play Console listing's "Privacy policy" field must point to
/// [privacyPolicyUrl], and [accountDeletionUrl] is the public web URL Google
/// requires for account/data deletion. [supportEmail] is where data requests go.
class LegalLinks {
  LegalLinks._();

  /// Hosted Privacy Policy (see docs/legal/PRIVACY_POLICY.md).
  static const String privacyPolicyUrl = 'https://steeltherapy.app/privacy';

  /// Hosted Terms of Use (see docs/legal/TERMS_OF_USE.md).
  static const String termsOfUseUrl = 'https://steeltherapy.app/terms';

  /// Public web page describing how to delete an account + data
  /// (Google Play account-deletion requirement).
  static const String accountDeletionUrl =
      'https://steeltherapy.app/delete-account';

  /// Support / data-request contact.
  static const String supportEmail = 'support@steeltherapy.app';

  /// Developer / legal entity name shown in the legal screens.
  static const String developerName = 'Steal Therapy';
}
