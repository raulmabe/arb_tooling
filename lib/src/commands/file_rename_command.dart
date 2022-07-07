// Copyright (c) 2022, Raul Mateo Beneyto
// https://raulmabe.dev
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:arb_tooling/src/config/file_rename_config.dart';
import 'package:arb_tooling/src/extensions/file_extensions.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template sample_command}
///
/// `arb2csv sample`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class FileRenameCommand extends Command<int> {
  /// {@macro sample_command}
  FileRenameCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption(
        inputPathKey,
        abbr: 'i',
        help: 'Path to the input directory. Defaults to current directory.',
        defaultsTo: './',
      )
      ..addOption(
        inputRegExpKey,
        mandatory: true,
        help: 'Name that you want to change.',
      )
      ..addOption(
        outputNameKey,
        mandatory: true,
        help: 'Name that will replace the current one.',
      );
  }

  late final FileRenameConfig config;

  int filesCount = 0;
  int dirCount = 0;

  String get inputPathKey => 'input-filepath';
  String get inputRegExpKey => 'from-name';
  String get outputNameKey => 'to-name';

  @override
  String get description =>
      'Renames all files that matches a RegExp. for another word.';

  @override
  String get name => 'file_rename';

  final Logger _logger;

  @override
  Future<int> run() async {
    try {
      //* Validate command config
      config = FileRenameConfig(
        inputDir: argResults?[inputPathKey] as String,
        inputName: argResults?[inputRegExpKey] as String,
        outputName: argResults?[outputNameKey] as String,
      );

      // * filesCount how many files match
      final dir = Directory(config.inputDir);

      //* Rename files
      final progressRenaming = _logger.progress('Renaming');
      await renameAllFilesFromDir(dir);
      progressRenaming
          .complete('Renamed $filesCount files and $dirCount directories');
    } catch (e) {
      _logger.err(e.toString());
      return ExitCode.ioError.code;
    }
    return ExitCode.success.code;
  }

  Future<List<Directory>> getAllDirFromDir(Directory dir) async {
    final entities = await dir.list().toList();
    return entities.whereType<Directory>().toList();
  }

  Future<List<File>> getAllFilesFromDir(Directory dir) async {
    final entities = await dir.list().toList();
    return entities.whereType<File>().toList();
  }

  Future<void> renameAllFilesFromDir(Directory dir) async {
    var cd = dir;

    //* Rename dir if matches
    if (cd.fileName.contains(config.inputName)) {
      cd = await cd.changeNameOnly(
        cd.fileName.replaceAll(RegExp(config.inputName), config.outputName),
      );
      dirCount++;
    }

    // * Get all elements from the directory
    final _dirs = await getAllDirFromDir(cd);
    final _files = await getAllFilesFromDir(cd);
    final files = _files
        .where((element) => element.fileName.contains(config.inputName))
        .toList();

    // * Rename all files in the directory
    for (final file in files) {
      await file.changeNameOnly(
        '${file.fileName}.${file.extensionType}'
            .replaceAll(RegExp(config.inputName), config.outputName),
      );
      filesCount++;
    }

    // * Rename the rest recursively
    for (final _dir in _dirs) {
      await renameAllFilesFromDir(_dir);
    }

    if (files.isEmpty) {
      return;
    }
  }
}
