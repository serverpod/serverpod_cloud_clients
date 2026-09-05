import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class PasswordListTextUi extends OutputWidget {
  const PasswordListTextUi();

  @override
  OutputWidget build(OutputContext context) {
    final passwords = context.get<List<Map<String, Object?>>>();
    if (passwords.isEmpty) {
      return const InfoTextWidget('No passwords available.');
    }

    final passwordsByCategory =
        <PasswordCategory, List<Map<String, Object?>>>{};
    for (final password in passwords) {
      final category = password['category'];
      if (category is PasswordCategory) {
        passwordsByCategory.putIfAbsent(category, () => []).add(password);
      }
    }

    return OutputWidgetList([
      const LineTextWidget(),
      for (final category in PasswordCategory.values)
        _SectionWidget(category, passwordsByCategory[category] ?? []),
    ]);
  }
}

class _SectionWidget extends OutputWidget {
  final PasswordCategory category;
  final List<Map<String, Object?>> passwords;

  const _SectionWidget(this.category, this.passwords);

  static final _tableFormatter = TextTableOutputFormatter<Map<String, Object?>>(
    columns: [
      TableColumnFormatter.forKey('Name', key: 'name'),
      TableColumnFormatter.forKey('Status', key: 'status'),
      TableColumnFormatter.forKey('Notes', key: 'notes'),
    ],
    utc: false,
  );

  @override
  OutputWidget build(OutputContext context) {
    if (category != PasswordCategory.custom && passwords.isEmpty) {
      return const OutputWidgetList([]);
    }

    return OutputWidgetList([
      const LineTextWidget(),
      LineTextWidget(category.displayName),
      const LineTextWidget(),
      TextTableWidget(_tableFormatter.format(passwords)),
      const LineTextWidget(),
    ]);
  }
}

class PasswordSetTextUi extends OutputWidget {
  final String baseCommand;

  const PasswordSetTextUi({required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final name = result['name'];
    final success = name is! String
        ? const SuccessTextWidget('Successfully set password.')
        : SuccessTextWidget('Successfully set password "$name".');
    return OutputWidgetList([
      success,
      CommandHintTextWidget(
        'The changes will not take effect until your server is re-deployed.',
        command: '$baseCommand deploy',
      ),
    ]);
  }
}

class PasswordUnsetTextUi extends OutputWidget {
  final String baseCommand;

  const PasswordUnsetTextUi({required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final name = result['name'];
    final success = name is! String
        ? const SuccessTextWidget('Successfully unset password.')
        : SuccessTextWidget('Successfully unset password "$name".');
    return OutputWidgetList([
      success,
      CommandHintTextWidget(
        'The changes will not take effect until your server is re-deployed.',
        command: '$baseCommand deploy',
      ),
    ]);
  }
}
