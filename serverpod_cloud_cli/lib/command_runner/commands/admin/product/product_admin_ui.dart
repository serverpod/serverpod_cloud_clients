import 'package:serverpod_cloud_cli/util/output/output.dart';

class ProductListUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const _ProductListTextUi());
  }
}

class _ProductListTextUi extends OutputWidget {
  const _ProductListTextUi();

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
