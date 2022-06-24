import 'package:arb_tooling/src/models/file_parser.dart';
import 'package:csv/csv.dart';

/// An extension of [FileParser] for files of type csv
class CSVParser extends FileParser {
  CSVParser({
    required super.file,
    required super.startIndex,
    required this.fieldDelimiter,
  });

  /// The delimiter to separate fields (i.e. `,` or `;`)
  final String fieldDelimiter;

  final CsvToListConverter _csvConverter = const CsvToListConverter();

  @override
  void parseFile() {
    final csv = file.readAsStringSync();

    final converted = _csvConverter.convert(
      csv,
      fieldDelimiter: fieldDelimiter,
    );
    for (final row in converted) {
      parsedContents.add(row.map((e) => e.toString()).toList());
    }
  }
}
