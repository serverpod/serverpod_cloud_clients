import 'package:cli_tools/cli_tools.dart';

abstract class CloudCliCommand extends BetterCommand {
  final Logger logger;
  CloudCliCommand({required this.logger})
      : super(
          logInfo: (final String message) => logger.info(message),
          wrapTextColumn: logger.wrapTextColumn,
        );
}
