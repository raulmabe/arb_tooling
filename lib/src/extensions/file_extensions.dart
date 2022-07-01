import 'dart:io';

extension FileExtension on File {
  String get extensionType => path.split('.').last.toLowerCase();

  bool get hasARBExtension => extensionType == 'arb';
  bool get hasJSONExtension => extensionType == 'json';
  bool get hasCSVExtension => extensionType == 'csv';
}
