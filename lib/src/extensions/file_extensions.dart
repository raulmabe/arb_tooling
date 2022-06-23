import 'dart:io';

extension FileExtension on File {
  String get extensionType => path.split('.').last.toLowerCase();

  bool get hasARBExtension => extensionType == 'arb';
}
