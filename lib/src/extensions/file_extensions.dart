import 'dart:io';

extension DirectoryExt on Directory {
  String get extensionType => path.split('.').last.toLowerCase();
  String get fileName =>
      path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);
  String get namelessPath =>
      path.substring(0, path.lastIndexOf(Platform.pathSeparator) + 1);

  Future<Directory> changeNameOnly(String newDirName) {
    final lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    final newPath = path.substring(0, lastSeparator + 1) + newDirName;
    return rename(newPath);
  }
}

extension FileExtension on File {
  String get extensionType => path.split('.').last.toLowerCase();
  String get fileName => path.split('/').last.split('.').first.toLowerCase();
  String get namelessPath =>
      path.substring(0, path.lastIndexOf(Platform.pathSeparator) + 1);

  Future<File> changeNameOnly(String newFileName) {
    final lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    final newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return rename(newPath);
  }

  bool get hasARBExtension => extensionType == 'arb';
  bool get hasJSONExtension => extensionType == 'json';
  bool get hasCSVExtension => extensionType == 'csv';
}
