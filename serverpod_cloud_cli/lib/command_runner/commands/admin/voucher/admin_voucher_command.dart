import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/voucher/voucher_admin_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/voucher/voucher_admin_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';

class AdminVoucherCommand extends CloudCliCommand {
  @override
  final name = 'voucher';

  @override
  final description = 'Voucher administration.';

  AdminVoucherCommand({required super.logger}) {
    addSubcommand(AdminCreateVoucherCommand(logger: logger));
    addSubcommand(AdminListVouchersCommand(logger: logger));
    addSubcommand(AdminArchiveVoucherCommand(logger: logger));
  }
}

enum AdminCreateVoucherOption<V> implements OptionDefinition<V> {
  code(
    StringOption(
      argName: 'code',
      argPos: 0,
      mandatory: true,
      helpText:
          'The code that owners enter. 3 to 32 letters, digits, hyphens and '
          'underscores. Can be passed as the first argument.',
    ),
  ),
  name(
    StringOption(
      argName: 'name',
      mandatory: true,
      helpText: 'The display name of the voucher.',
    ),
  ),
  amount(
    StringOption(
      argName: 'amount',
      mandatory: true,
      helpText: 'The credit per redemption in US dollars, such as 60 or 59.99.',
      valueHelp: 'dollars',
    ),
  ),
  paysFor(
    MultiStringOption(
      argName: 'pays-for',
      helpText:
          'The billing items the credit pays, such as starterFee. '
          'Repeat or comma-separate. Defaults to all items.',
      valueHelp: 'billing item',
      defaultsTo: [],
    ),
  ),
  redeemableUntil(
    DateTimeOption(
      argName: 'redeemable-until',
      helpText:
          'The last moment the voucher can be redeemed. '
          'Defaults to no deadline.',
    ),
  ),
  creditLifetimeDays(
    IntOption(
      argName: 'credit-lifetime-days',
      helpText:
          'How many days the credit lasts after a redemption. '
          'Defaults to no limit.',
      min: 1,
    ),
  ),
  creditExpiresBy(
    DateTimeOption(
      argName: 'credit-expires-by',
      helpText:
          'The latest moment the credit expires, whenever it is redeemed. '
          'Defaults to none.',
    ),
  ),
  maxRedemptions(
    IntOption(
      argName: 'max-redemptions',
      helpText:
          'How many times the voucher can be redeemed in total. '
          'Defaults to no limit.',
      min: 1,
    ),
  ),
  maxRedemptionsPerOwner(
    IntOption(
      argName: 'max-redemptions-per-owner',
      helpText: 'How many times one owner can redeem the voucher.',
      defaultsTo: 1,
      min: 1,
    ),
  ),
  utc(UtcOption());

  const AdminCreateVoucherOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminCreateVoucherCommand
    extends CloudCliCommand<AdminCreateVoucherOption> {
  static final _dollars = RegExp(r'^(\d{1,7})(?:\.(\d{1,2}))?$');

  @override
  final name = 'create';

  @override
  final description =
      'Create a voucher. A voucher cannot be changed after it is created.';

  AdminCreateVoucherCommand({required super.logger})
    : super(options: AdminCreateVoucherOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminCreateVoucherOption> commandConfig,
    final CommandOutput output,
  ) async {
    final code = commandConfig.value(AdminCreateVoucherOption.code);
    final name = commandConfig.value(AdminCreateVoucherOption.name);
    final creditAmountCents = _parseCents(
      commandConfig.value(AdminCreateVoucherOption.amount),
    );
    final paysFor = commandConfig.value(AdminCreateVoucherOption.paysFor);
    final redeemableUntil = commandConfig.optionalValue(
      AdminCreateVoucherOption.redeemableUntil,
    );
    final creditLifetimeDays = commandConfig.optionalValue(
      AdminCreateVoucherOption.creditLifetimeDays,
    );
    final creditExpiresBy = commandConfig.optionalValue(
      AdminCreateVoucherOption.creditExpiresBy,
    );
    final maxRedemptions = commandConfig.optionalValue(
      AdminCreateVoucherOption.maxRedemptions,
    );
    final maxRedemptionsPerOwner = commandConfig.value(
      AdminCreateVoucherOption.maxRedemptionsPerOwner,
    );
    final utc = commandConfig.value(AdminCreateVoucherOption.utc);

    await renderCommand(
      output,
      operation: () => VoucherAdminOperations.createVoucher(
        runner.serviceProvider.cloudApiClient,
        code: code,
        name: name,
        creditAmountCents: creditAmountCents,
        paysForItemIds: paysFor,
        redeemableUntil: redeemableUntil,
        creditLifetimeDays: creditLifetimeDays,
        creditExpiresBy: creditExpiresBy,
        maxRedemptions: maxRedemptions,
        maxRedemptionsPerOwner: maxRedemptionsPerOwner,
      ),
      textOutputUi: AdminVoucherCreateTextUi(utc: utc),
    );
  }

  static int _parseCents(final String dollars) {
    final match = _dollars.firstMatch(dollars.trim());
    if (match == null) {
      throw CloudCliUsageException(
        'Invalid amount "$dollars".',
        hint: 'Give the amount in US dollars, such as 60 or 59.99.',
      );
    }
    final wholeDollars = int.parse(match.group(1) ?? '0');
    final cents = (match.group(2) ?? '').padRight(2, '0');
    return wholeDollars * 100 + int.parse(cents);
  }
}

enum AdminListVouchersOption<V> implements OptionDefinition<V> {
  includeArchived(
    FlagOption(
      argName: 'include-archived',
      helpText: 'Include the archived vouchers.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  utc(UtcOption());

  const AdminListVouchersOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminListVouchersCommand
    extends CloudCliCommand<AdminListVouchersOption> {
  @override
  final name = 'list';

  @override
  final description = 'List the vouchers, newest first.';

  AdminListVouchersCommand({required super.logger})
    : super(options: AdminListVouchersOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminListVouchersOption> commandConfig,
    final CommandOutput output,
  ) async {
    final includeArchived = commandConfig.value(
      AdminListVouchersOption.includeArchived,
    );
    final utc = commandConfig.value(AdminListVouchersOption.utc);

    await renderCommand(
      output,
      operation: () => VoucherAdminOperations.listVouchers(
        runner.serviceProvider.cloudApiClient,
        includeArchived: includeArchived,
      ),
      textOutputUi: AdminVoucherListTextUi(utc: utc),
    );
  }
}

enum AdminArchiveVoucherOption<V> implements OptionDefinition<V> {
  code(
    StringOption(
      argName: 'code',
      argPos: 0,
      mandatory: true,
      helpText:
          'The code of the voucher. '
          'Can be passed as the first argument.',
    ),
  ),
  utc(UtcOption());

  const AdminArchiveVoucherOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AdminArchiveVoucherCommand
    extends CloudCliCommand<AdminArchiveVoucherOption> {
  @override
  final name = 'archive';

  @override
  final description =
      'Archive a voucher. It can no longer be redeemed, granted credit '
      'stays in place, and this cannot be undone.';

  AdminArchiveVoucherCommand({required super.logger})
    : super(options: AdminArchiveVoucherOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AdminArchiveVoucherOption> commandConfig,
    final CommandOutput output,
  ) async {
    final code = commandConfig.value(AdminArchiveVoucherOption.code);
    final utc = commandConfig.value(AdminArchiveVoucherOption.utc);

    await confirmToContinue(
      output,
      message:
          'Are you sure you want to archive the voucher "$code"? '
          'This cannot be undone.',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => VoucherAdminOperations.archiveVoucher(
        runner.serviceProvider.cloudApiClient,
        code: code,
      ),
      textOutputUi: AdminVoucherArchiveTextUi(utc: utc),
    );
  }
}
