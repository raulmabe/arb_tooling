import 'dart:io';

extension FileExtension on File {
  String get extensionType => path.split('.').last.toLowerCase();
  String get fileName => path.split('/').last.split('.').first.toLowerCase();
  String get namelessPath =>
      path.substring(0, path.lastIndexOf(Platform.pathSeparator) + 1);

  bool get hasARBExtension => extensionType == 'arb';
  bool get hasJSONExtension => extensionType == 'json';
  bool get hasCSVExtension => extensionType == 'csv';
}
