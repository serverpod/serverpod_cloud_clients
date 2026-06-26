// ignore_for_file: avoid_print

import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

/// Manual demo for the inline_tui select list.
///
/// Run interactively with: `dart run example/inline_tui_select_list_demo.dart`
Future<void> main() async {
  print('Some output above the list is preserved.\n');

  // The caller owns the terminal's lifecycle: create it once and dispose it
  // when completely done so the shared stdin subscription is released and the
  // process can exit.
  final terminal = StdioTerminal();
  try {
    final fruit = await SelectList.choose<String>(
      prompt: 'Pick a fruit:',
      options: ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'],
      terminal: terminal,
    );
    print('You chose: $fruit\n');

    final toppings = await SelectList.chooseMultiple<String>(
      prompt: 'Pick toppings (space to toggle, enter to confirm):',
      options: ['Sprinkles', 'Caramel', 'Nuts', 'Whipped cream'],
      minSelections: 1,
      terminal: terminal,
    );
    print('Toppings: $toppings');
  } finally {
    await terminal.dispose();
  }
}
