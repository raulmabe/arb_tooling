// Copyright (c) 2022, Raul Mateo Beneyto
// https://raulmabe.dev
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:convert';
import 'dart:io';

import 'package:arb_tooling/src/config/from_csv_config.dart';
import 'package:arb_tooling/src/extensions/string_extensions.dart';
import 'package:arb_tooling/src/models/arb_file.dart';
import 'package:arb_tooling/src/models/csv_parser.dart';
import 'package:arb_tooling/src/utils/file_writer.dart';
import 'package:arb_tooling/src/utils/validator.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template sample_command}
///
/// `arb2csv sample`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class FromCSVCommand extends Command<int> {
  /// {@macro sample_command}
  FromCSVCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption(
        inputPathKey,
        abbr: 'i',
        help: 'Path to the input CSV file',
      )
      ..addOption(
        inputURLKey,
        abbr: 'u',
        help: 'URL to the input CSV file',
      )
      ..addOption(
        outputDirectoryKey,
        abbr: 'o',
        mandatory: true,
        help: 'Path to the output directory for ARB files',
      )
      ..addOption(
        filenamePrependKey,
        abbr: 'p',
        help: 'Text to prepend to filename of generated ARB files.',
      )
      ..addFlag(
        'json',
      );
  }

  late final FromCSVConfig config;

  String get inputPathKey => 'input-filepath';
  String get inputURLKey => 'input-url';
  String get filenamePrependKey => 'filename-prepend';
  String get outputDirectoryKey => 'output-directory';

  @override
  String get description => 'Transforms CSV to ARB';

  @override
  String get name => 'from_csv';

  final Logger _logger;

  @override
  Future<int> run() async {
    const fieldDelimiter = ',';
    const startIndex = 2;
    const descriptionIndex = 1;

    try {
      //* Validate command config
      config = FromCSVConfig(
        inputFilepath: argResults?[inputPathKey] as String?,
        urlFile: argResults?[inputURLKey] as String?,
        outputDir: (argResults?[outputDirectoryKey] as String).noTrailingSlash,
        filePrependName: argResults?[filenamePrependKey] as String? ?? '',
        useJsonExtension: argResults?['json'] as bool? ?? false,
      );

      if (config.urlFile == null && config.inputFilepath == null) {
        throw ArgumentError(
          '''You must specify an input file, whether is from an url or local path''',
        );
      }

      //* Build File
      final filePath = config.inputFilepath;
      late final File file;
      var isFileTemporal = false;
      if (filePath != null) {
        file = File(filePath);
        Validator.validateFile(file, 'csv');
      } else {
        isFileTemporal = true;
        final downloadProgress = _logger.progress('Downloading CSV');
        try {
          file = await getFileFromURL(config.urlFile!);
          downloadProgress.complete('Downloaded CSV');
        } catch (e) {
          downloadProgress.cancel();
          rethrow;
        }
      }

      // * Parse file to CSV
      final parsingProgress = _logger.progress('Parsing CSV to ARB');
      final parser = CSVParser(
        file: file,
        startIndex: startIndex,
        fieldDelimiter: fieldDelimiter,
      );

      // * Validate parsed file
      final supportedLanguages = parser.supportedLanguages;

      Validator.validateSupportedLanguages(supportedLanguages);

      final localizationsTable = parser.localizationsTable;

      _logger.detail('Locales detected $supportedLanguages');
      parsingProgress.complete('Parsed ${localizationsTable.length} key(s)');

      for (final _row in localizationsTable) {
        Validator.validateLocalizationTableRow(
          _row,
          numberSupportedLanguages: supportedLanguages.length,
        );
      }

      //* Generate a file for each supported language
      for (final supportedLanguage in supportedLanguages) {
        final content = _generateARBFile(
          language: supportedLanguage,
          keys: parser.keys,
          values: parser.getValues(supportedLanguage),
          defaultValues: parser.defaultValues,
          descriptions: parser.getColumn(descriptionIndex),
          placeholders: parser.getPlaceholders(),
        );

        const encoder = JsonEncoder.withIndent('     ');
        final jsonPretty = encoder.convert(content.toMap());

        final extension = config.useJsonExtension ? 'json' : 'arb';
        //* Write content to file
        final path =
            '${config.outputDir}/${config.filePrependName}$supportedLanguage.$extension';
        FileWriter().write(
          contents: jsonPretty,
          path: path,
        );

        _logger.success('Generated $path');
      }

      if (isFileTemporal) {
        await file.delete();
      }
    } catch (e) {
      _logger.err(e.toString());
      return ExitCode.ioError.code;
    }
    return ExitCode.success.code;
  }

  ARBFile _generateARBFile({
    required String language,
    required List<String> keys,
    required List<String> values,
    required List<String> defaultValues,
    List<String>? descriptions,
    List<List<String>>? placeholders,
  }) {
    if (keys.length != values.length && keys.length != defaultValues.length) {
      throw ArgumentError('Mismatch number of keys and values');
    }

    final messages = <Message>[];
    for (var i = 0; i < keys.length; i++) {
      final hasPlaceholders =
          placeholders?[i] != null && placeholders![i].isNotEmpty;
      final value = i < values.length && values[i].isNotEmpty
          ? values[i]
          : defaultValues[i];
      messages.add(
        Message(
          key: keys[i],
          value: value,
          description: descriptions?[i],
          placeholders: hasPlaceholders
              ? {
                  for (final placeholder in placeholders[i])
                    placeholder: <String, dynamic>{}
                }
              : null,
        ),
      );
    }
    final file = ARBFile(locale: language, messages: messages);
    return file;
  }

  Future<File> getFileFromURL(String url) async {
    const tmpPath = 'tmp.csv';
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    await response.pipe(
      File(tmpPath).openWrite(),
    );
    final file = File(tmpPath);

    Validator.validateFile(file, 'csv');
    return file;
  }
}
