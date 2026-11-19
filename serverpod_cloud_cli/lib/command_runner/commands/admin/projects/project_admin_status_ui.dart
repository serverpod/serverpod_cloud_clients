import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_status_lines.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminProjectStatusTextUi extends OutputWidget {
  final bool utc;

  AdminProjectStatusTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    return _AdminProjectStatusPanel(
      info: context.get<AdminProjectInfo>(),
      utc: utc,
    );
  }
}

class _AdminProjectStatusPanel extends OutputWidget {
  final AdminProjectInfo info;
  final bool utc;

  const _AdminProjectStatusPanel({required this.info, required this.utc});

  @override
  void render({required CommandLogger logger}) {
    logger.line('');
    for (final line in AdminProjectStatusLines(
      logger: logger,
      info: info,
      utc: utc,
    ).build()) {
      logger.line(line);
    }
  }
}
