import 'dart:io';

import 'package:arb_tooling/src/config/constants.dart' as constants;
import 'package:arb_tooling/src/extensions/file_extensions.dart';
import 'package:arb_tooling/src/extensions/string_extensions.dart';
import 'package:arb_tooling/src/models/file_parser.dart';

abstract class Validator {
  /// Validates whether [file] is valid
  ///
  /// If any error occurs, process is derminated
  static void validateFile(File file, String extension) {
    // check that the file exists
    if (!file.existsSync()) {
      throw ArgumentError('File ${file.path} does not exist!');
    }

    // check that the file extension is correct
    if (file.extensionType != extension) {
      throw ArgumentError(
        '''File ${file.path} has extension ${file.extensionType} which is not $extension, which is the expected!''',
      );
    }
  }

  /// Validates whether [supportedLanguages] are valid
  ///
  /// If any error occurs, process is derminated
  static void validateSupportedLanguages(List<String> supportedLanguages) {
    for (final supportedLanguage in supportedLanguages) {
      if (!supportedLanguage.isValidLocale) {
        throw ArgumentError(
          '''$supportedLanguage isn't a valid locale. Expected locale of the form "en" or "en_US".''',
        );
      }

      final languageCode = supportedLanguage.split('_').first;
      if (!constants.flutterLocalizedLanguages.contains(languageCode)) {
        throw ArgumentError(
          "$languageCode isn't supported by default in Flutter. Please see https://flutter.dev/docs/development/accessibility-and-localization/internationalization#adding-support-for-a-new-language for info on how to add required classes.",
        );
      }
    }
  }

  /// Validates whether [row] is valid
  ///
  /// If any error occurs, process is derminated
  static void validateLocalizationTableRow(
    LocalizationTableRow row, {
    required int numberSupportedLanguages,
  }) {
    final key = row.key;
    if (constants.reservedWords.contains(key)) {
      throw ArgumentError(
        'Key $key in row ${row.raw} is a reserved keyword in Dart and is thus invalid.',
      );
    }

    if (constants.types.contains(key)) {
      throw ArgumentError(
        'Key $key in row ${row.raw} is a type in Dart and is thus invalid.',
      );
    }

    if (!key.isValidVariableName) {
      throw ArgumentError(
        '''Key $key in row ${row.raw} is invalid. Expected key in the form lowerCamelCase.''',
      );
    }

    final words = row.words;
    if (words.length > numberSupportedLanguages) {
      throw ArgumentError(
        '''The row ${row.raw} does not seem to be well formatted. Found ${words.length} values for numberSupportedLanguages locales.''',
      );
    }

    final defaultWord = row.defaultWord;
    if (defaultWord.isEmpty) {
      throw ArgumentError(
        'Key $key in row ${row.raw} has no translation for default language.',
      );
    }
  }
}
