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
        defaultsTo: '/',
      )
      ..addOption(
        inputRegExpKey,
        mandatory: true,
        help: 'Name or RegExp that you want to change.',
      )
      ..addOption(
        outputNameKey,
        mandatory: true,
        help: 'Name that will replace the current one.',
      );
  }

  late final FileRenameConfig config;

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

      // * Count how many files match
      final dir = Directory(config.inputDir);

      final entities = await dir.list().toList();

      final files = entities
          .whereType<File>()
          .where((element) => element.fileName.contains(config.inputName))
          .toList();

      if (files.isEmpty) {
        _logger.warn('0 files matched with "${config.inputName}"');
        return ExitCode.noInput.code;
      }

      _logger.alert(
        'Found ${files.length}/${entities.length} files that match ${config.inputName}',
      );

      //* Rename files
      final progressRenaming = _logger.progress('Renaming');
      for (final file in files) {
        file.renameSync(
          file.path.replaceAll(RegExp(config.inputName), config.outputName),
        );
      }
      progressRenaming.complete();
    } catch (e) {
      _logger.err(e.toString());
      return ExitCode.ioError.code;
    }
    return ExitCode.success.code;
  }
}
