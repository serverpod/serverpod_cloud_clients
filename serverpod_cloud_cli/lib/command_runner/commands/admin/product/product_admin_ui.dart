import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ProductListTextUi extends OutputWidget {
  const ProductListTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forKey('Product', key: 'name'),
          TableColumnFormatter.forKey('Type', key: 'type'),
        ],
        utc: false,
      ),
    );
  }
}

class ProductProcureTextUi extends OutputWidget {
  const ProductProcureTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'The plan ${result['planName']} has been procured for the user.',
      newParagraph: true,
    );
  }
}

class ProductCancelTextUi extends OutputWidget {
  const ProductCancelTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return const SuccessTextWidget(
      "The user's plan has been cancelled.",
      newParagraph: true,
    );
  }
}
