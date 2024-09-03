import 'dart:io';

abstract final class BrowserLauncher {
  static Future<ProcessResult> openUrl(final Uri url) async {
    return Process.run(
      _getPlatformBrowserCommand(),
      [url.toString()],
      runInShell: true,
    );
  }

  static String _getPlatformBrowserCommand() {
    if (Platform.isWindows) {
      return 'start';
    } else if (Platform.isLinux) {
      return 'xdg-open';
    } else if (Platform.isMacOS) {
      return 'open';
    }
    throw Exception('Unsupported platform: ${Platform.operatingSystem}.');
  }
}
