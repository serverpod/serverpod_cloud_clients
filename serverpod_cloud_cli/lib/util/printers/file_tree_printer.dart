import 'dart:math';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;

class _TreeNode {
  final String part;
  bool isIgnored;

  _TreeNode(this.part, this.isIgnored);

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is _TreeNode && part == other.part;
  }

  @override
  int get hashCode => part.hashCode;

  @override
  String toString() {
    return part;
  }
}

abstract final class FileTreePrinter {
  static const int _maxLength = 80;

  static void writeFileTree({
    required final Set<String> filePaths,
    required final Set<String> ignoredPaths,
    required final void Function(String, {AnsiStyle? style}) write,
  }) {
    final List<_TreeNode> allFiles = [
      ...filePaths.map((final path) => _TreeNode(path, false)),
      ...ignoredPaths.map((final path) => _TreeNode(path, true)),
    ];

    // Sort files by directory structure
    // Files comes after directories, and directories are sorted alphabetically
    //
    // Example of sorted output:
    // a/b/z.dart
    // a/z/a.dart
    // z/a.dart
    // a.dart
    allFiles.sort((final a, final b) {
      final aDirs = p.split(a.part);
      final bDirs = p.split(b.part);

      final minParts = min(aDirs.length, bDirs.length);

      for (var i = 0; i < minParts; i++) {
        final isLast = i == minParts - 1;
        if (isLast && aDirs.length != bDirs.length) {
          // If paths are different lengths, directories (longer paths) come first
          return bDirs.length.compareTo(aDirs.length);
        }

        // If parts are different at this level, sort alphabetically
        if (aDirs[i] != bDirs[i]) {
          return aDirs[i].compareTo(bDirs[i]);
        }
      }

      return 0;
    });

    final tree = _buildTree(allFiles);

    _writeTree(tree, write, isParentIgnored: filePaths.isEmpty);
  }

  static Map<_TreeNode, dynamic> _buildTree(final List<_TreeNode> files) {
    final Map<_TreeNode, dynamic> root = {};

    for (final _TreeNode file in files) {
      final List<_TreeNode> parts = p
          .split(file.part)
          .map(
            (final part) => _TreeNode(part, file.isIgnored),
          )
          .toList();

      Map<_TreeNode, dynamic> current = root;

      for (final part in parts) {
        if (!part.isIgnored && current.containsKey(part)) {
          current.keys.firstWhere((final e) => e == part).isIgnored = false;
        }

        current = current.putIfAbsent(part, () => <_TreeNode, dynamic>{});
      }
    }

    return root;
  }

  static void _writeTree(
    final Map<_TreeNode, dynamic> tree,
    final void Function(String, {AnsiStyle? style}) write, {
    final List<(String, AnsiStyle?)> prefixes = const [],
    final bool isParentIgnored = false,
  }) {
    final List<_TreeNode> nodes = tree.keys.toList();

    for (int i = 0; i < nodes.length; i++) {
      final _TreeNode node = nodes[i];

      final bool isLast = i == nodes.length - 1;

      _writeNode(
        node: node,
        isLast: isLast,
        isParentIgnored: isParentIgnored,
        prefixes: prefixes,
        write: write,
      );

      final parentStyle = _style(isParentIgnored);
      final nextPrefixes = [
        ...prefixes,
        (_prefix(isLast, isParentIgnored), parentStyle),
      ];

      final dynamic value = tree[node];
      if (value is Map<_TreeNode, dynamic>) {
        //recursion
        _writeTree(
          value,
          write,
          prefixes: nextPrefixes,
          isParentIgnored: node.isIgnored,
        );
      }
    }
  }

  static AnsiStyle? _style(final bool isIgnored) {
    return isIgnored ? AnsiStyle.darkGray : null;
  }

  static void _writeNode({
    required final _TreeNode node,
    required final bool isLast,
    required final bool isParentIgnored,
    required final List<(String, AnsiStyle?)> prefixes,
    required final void Function(String, {AnsiStyle? style}) write,
  }) {
    final AnsiStyle? style = _style(node.isIgnored);
    final AnsiStyle? parentStyle = _style(isParentIgnored);

    for (final (prefix, style) in prefixes) {
      write(prefix, style: style);
    }

    final connector = _connector(isLast, isParentIgnored);
    write(connector, style: parentStyle);

    if (node.isIgnored) {
      final ignoredAnnotation = ' (ignored)';

      final prefix = prefixes.fold(
        '',
        (final fullPrefix, final prefixNode) => fullPrefix + prefixNode.$1,
      );

      final paddingLength = _maxLength -
          prefix.length -
          connector.length -
          node.part.length -
          ignoredAnnotation.length;

      final String paddingString = ' ' * paddingLength;

      write(node.part, style: style);
      write(paddingString, style: style);
      write(ignoredAnnotation, style: style);
    } else {
      write(node.part, style: style);
    }
    write('\n', style: style);
  }

  static String _connector(final bool isLast, final bool parentIgnored) {
    if (parentIgnored) {
      return isLast ? '╰╌ ' : '┆╌ ';
    } else {
      return isLast ? '╰─ ' : '├─ ';
    }
  }

  static String _prefix(final bool isLast, final bool parentIgnored) {
    final l = parentIgnored ? '┆' : '│';
    return isLast ? '   ' : '$l  ';
  }
}
