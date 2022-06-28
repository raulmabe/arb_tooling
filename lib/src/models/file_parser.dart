import 'dart:io';

import 'package:meta/meta.dart';

/// A base file parser which should be extended by supported file times
abstract class FileParser {
  FileParser({
    required this.file,
    required this.startIndex,
  }) : assert(startIndex > 0, 'startIndex must be greater than 0') {
    eraseParsedContents();
    parseFile();
  }

  /// The number of header lines (ie rows) before localizations start
  static const int _numberHeaderLines = 1;

  /// The file to parse
  final File file;

  /// The (column) index where localizations start
  final int startIndex;

  /// A 2D list of parsed localizations
  late List<List<String>> parsedContents;

  /// Erases all parsed content
  @protected
  @visibleForTesting
  void eraseParsedContents() => parsedContents = <List<String>>[];

  /// Parses the file. All base classes must implement this method.
  @protected
  void parseFile();

  /// Returns the localized languages (i.e. fr, en_GB)
  List<String> get supportedLanguages {
    if (parsedContents.isEmpty) {
      throw RangeError('File contents have not been parsed yet.');
    }

    return parsedContents.first.sublist(startIndex);
  }

  /// Returns a table of localizations (excluding supported languages)
  List<LocalizationTableRow> get localizationsTable {
    if (parsedContents.isEmpty) {
      throw RangeError('File contents have not been parsed yet.');
    }

    final locaTable = parsedContents.sublist(_numberHeaderLines);
    return locaTable
        .map(
          (row) => LocalizationTableRow(
            key: row.first,
            defaultWord: row.sublist(startIndex).first,
            words: row.sublist(startIndex),
            raw: row,
          ),
        )
        .toList(growable: false);
  }

  List<List<String>> getPlaceholders() {
    final values = getColumn(startIndex);
    final vars = <List<String>>[];
    for (final value in values) {
      final regex = RegExp(r'\{[a-zA-Z]+(\}|\,)');
      final placeholders = regex.allMatches(value);
      final strings = placeholders
          .map((e) => e[0].toString().substring(1, e[0].toString().length - 1))
          .toList();

      if (strings.length > 1 &&
          (value.contains('plural') || value.contains('select'))) {
        strings.removeRange(1, strings.length);
      }

      vars.add(strings);
    }
    return vars;
  }

  /// Returns a column from localizations table
  List<String> getColumn(int index) => parsedContents
      .sublist(_numberHeaderLines)
      .map((row) => row[index])
      .toList(growable: false);

  /// Returns all localization keys
  List<String> get keys => getColumn(0);

  /// Returns all localizations values for a language
  List<String> getValues(String language) {
    if (!supportedLanguages.contains(language)) {
      throw RangeError('Language $language is not part of parsed contents.');
    }

    return getColumn(parsedContents.first.indexOf(language));
  }

  /// Returns all localizations values for the default language
  List<String> get defaultValues => getColumn(startIndex);
}

/// A model representing a row in a `LocalizationTable`
@immutable
class LocalizationTableRow {
  const LocalizationTableRow({
    required this.key,
    required this.defaultWord,
    required this.words,
    required this.raw,
  });

  /// The localization key
  final String key;

  /// The default word (i.e. value for default language)
  final String defaultWord;

  /// All translations
  final List<String> words;

  /// The raw content
  final List<String> raw;

  @override
  bool operator ==(Object other) =>
      other is LocalizationTableRow &&
      key == other.key &&
      defaultWord == other.defaultWord &&
      _listEquals(words, other.words) &&
      _listEquals(raw, other.raw);

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() =>
      '{key: $key, defaultWord: $defaultWord, words: $words, raw: $raw}';
}

/// Compares two lists for deep equality.
/// Returns true if the lists are both null, or if they are both non-null, have
/// the same length, and contain the same members in the same order.
/// Returns false otherwise.
///
/// The term "deep" above refers to the first level of equality: if the elements are maps, lists, sets, or other collections/composite objects, then the values of those elements are not compared element by element unless their equality operators (Object.==) do so.
///
/// Taken from Flutter foundation https://api.flutter.dev/flutter/foundation/listEquals.html
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (var index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}
