// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:arb_tooling/src/extensions/file_extensions.dart';
import 'package:arb_tooling/src/models/arb_file.dart';
import 'package:args/command_runner.dart';
import 'package:csv/csv.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template sample_command}
///
/// `arb2csv sample`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class ToCSVCommand extends Command<int> {
  /// {@macro sample_command}
  ToCSVCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser.addOption(
      'input_folder',
      abbr: 'i',
      mandatory: true,
      help: 'Specifies the ARB input folder',
    );
  }

  @override
  String get description => 'Transforms ARB to CSV';

  @override
  String get name => 'to_csv';

  final Logger _logger;

  @override
  Future<int> run() async {
    try {
      final folderPath = argResults?['input_folder'] as String?;
      if (folderPath == null) {
        throw ArgumentError('input_folder was not specified.');
      }
      final dir = Directory(folderPath);

      final entities = await dir.list().toList();

      final files = entities
          .whereType<File>()
          .where((element) => element.hasARBExtension)
          .toList();

      if (files.isEmpty) throw ArgumentError('No ARB files found.');

      final parsingFiles = files.map((e) => e.readAsString());
      final parsedContent = await Future.wait(parsingFiles);
      final parsingProgress = _logger.progress('Parsing');
      final parsedFiles = parsedContent.map(ARBFile.fromJson).toList();
      final supportedLanguages = parsedFiles.map((e) => e.locale).toList();
      parsingProgress.complete('Parsing complete $supportedLanguages');

      final csvList = [
        ['key', 'description', ...supportedLanguages.reversed],
      ];

      for (var i = 0; i < parsedFiles.first.messages.length; ++i) {
        csvList.add([
          parsedFiles[0].messages[i].key,
          parsedFiles[0].messages[i].description!,
          for (int j = 0; j < parsedFiles.length; ++j) ...[
            parsedFiles.reversed.toList()[j].messages[i].value,
          ]
        ]);
      }

      final csvString = const ListToCsvConverter(
              // eol: '\n',
              )
          .convert(csvList, eol: '\r\n');

      const filename = 'translations.csv';
      const path = 'example/output/$filename';
      await File(path).writeAsString(csvString);

      _logger.success('File $filename created successfully in $path');
    } catch (e) {
      _logger.err(e.toString());
      return ExitCode.ioError.code;
    }
    return ExitCode.success.code;
  }
}
