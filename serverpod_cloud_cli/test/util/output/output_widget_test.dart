import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:serverpod_cloud_cli/util/output/output_widget.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

class _RecordingWidget extends OutputWidget {
  final String name;

  const _RecordingWidget(this.name);

  @override
  void render({required final CommandLogger logger}) {
    logger.info(name);
  }
}

class _NestedWidget extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return const _RecordingWidget('child');
  }

  @override
  void render({required final CommandLogger logger}) {
    logger.info('parent');
  }
}

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a leaf widget', () {
    test('when rendered then the widget writes its output', () {
      const _RecordingWidget(
        'leaf',
      ).buildTree(OutputContext(OutputFormat.text)).renderTree(logger: logger);

      expect(logger.infoCalls, [equalsInfoCall(message: 'leaf')]);
    });
  });

  group('Given a widget that builds a child', () {
    test('when rendered then the parent is written before the child', () {
      _NestedWidget()
          .buildTree(OutputContext(OutputFormat.text))
          .renderTree(logger: logger);

      expect(logger.infoCalls, [
        equalsInfoCall(message: 'parent'),
        equalsInfoCall(message: 'child'),
      ]);
    });
  });
}
