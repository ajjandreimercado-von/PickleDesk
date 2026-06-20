import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains('AppTheme')) {
      // Very naive regex to remove const from structures wrapping AppTheme
      content = content.replaceAll(RegExp(r'const\s+([A-Z][a-zA-Z0-9_]*\s*\([^)]*AppTheme\.[a-zA-Z0-9_]+[^)]*\))'), r'$1');
      // Also catch nested like const BorderSide(color: AppTheme.border)
      // Actually simpler: just remove `const` keyword if it's on the same line as AppTheme
      // Wait, that might remove valid consts.
      // Let's use a regex to remove const before Text, BorderSide, EdgeInsets, ColorScheme, BoxDecoration, Icon
      final targets = ['Text', 'BorderSide', 'EdgeInsets', 'ColorScheme', 'BoxDecoration', 'Icon', 'TextStyle', 'IconThemeData', 'NavigationBarThemeData'];
      for (final t in targets) {
        content = content.replaceAll(RegExp('const\\s+$t\\('), '$t(');
      }
      
      // also const Color(0xE0111410) etc inside AppTheme
      if (file.path.endsWith('app_theme.dart')) {
        content = content.replaceAll('const ColorScheme.dark', 'ColorScheme.dark');
        content = content.replaceAll('const FloatingActionButtonThemeData', 'FloatingActionButtonThemeData');
        content = content.replaceAll('const NavigationRailThemeData', 'NavigationRailThemeData');
        content = content.replaceAll('const DividerThemeData', 'DividerThemeData');
        content = content.replaceAll('const IconThemeData', 'IconThemeData');
      }
      
      file.writeAsStringSync(content);
    }
  }
}
