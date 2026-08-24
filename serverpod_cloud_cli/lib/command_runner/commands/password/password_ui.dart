import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart';

class PasswordListUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const _PasswordListTextUi());
  }
}

class _PasswordListTextUi extends OutputWidget {
  const _PasswordListTextUi();

  @override
  OutputWidget build(final OutputContext context) {
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

    return _WidgetList([
      const _LineWidget(),
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
  OutputWidget build(final OutputContext context) {
    if (category != PasswordCategory.custom && passwords.isEmpty) {
      return const _WidgetList([]);
    }

    return _WidgetList([
      const _LineWidget(),
      _LineWidget(category.displayName),
      const _LineWidget(),
      TextTableWidget(_tableFormatter.format(passwords)),
      const _LineWidget(),
    ]);
  }
}

class _WidgetList extends OutputWidget {
  final List<OutputWidget> children;

  const _WidgetList(this.children);

  @override
  WidgetNode buildTree(final OutputContext context) {
    return WidgetNode(
      widget: this,
      children: [for (final child in children) child.buildTree(context)],
    );
  }
}

class _LineWidget extends OutputWidget {
  final String line;

  const _LineWidget([this.line = '']);

  @override
  void render({required final CommandLogger logger}) {
    logger.line(line);
  }
}

class PasswordSetUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const _PasswordSetTextUi());
  }
}

class _PasswordSetTextUi extends OutputWidget {
  const _PasswordSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final name = result['name'];
    if (name is! String) {
      return const SuccessTextWidget('Successfully set password.');
    }
    return SuccessTextWidget('Successfully set password "$name".');
  }
}

class PasswordUnsetUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const _PasswordUnsetTextUi());
  }
}

class _PasswordUnsetTextUi extends OutputWidget {
  const _PasswordUnsetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final name = result['name'];
    if (name is! String) {
      return const SuccessTextWidget('Successfully unset password.');
    }
    return SuccessTextWidget('Successfully unset password "$name".');
  }
}
