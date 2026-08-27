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
