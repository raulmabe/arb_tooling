import 'package:arb_tooling/src/models/csv_settings.dart';

class FromCSVSettings extends CSVSettings {
  const FromCSVSettings({
    required this.inputFilepath,
    this.outputDir = '',
    this.filePrependName = '',
    super.baseIndex,
    super.descriptionIndex,
    super.eol,
    super.delimiter,
  });

  /// Required.
  ///
  /// Specifies the path where CSV file is.
  final String inputFilepath;

  /// A directory to generate the output ARB files.
  final String outputDir;

  /// Specifies the text to prepend to each ARB file
  ///
  /// Defaults to empty string.
  final String filePrependName;
}
