import 'package:serverpod_cloud_cli/util/output/output.dart';

class BackfillSubscriptionStatesTextUi extends OutputWidget {
  const BackfillSubscriptionStatesTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return const SuccessTextWidget(
      'Started the subscription state backfill.',
      followUp:
          'The backfill runs on the server. See the server log for the counts'
          ' of subscriptions inserted, unpaid, recorded before, and failed.',
      newParagraph: true,
    );
  }
}
