import 'package:arb_tooling/src/models/csv_settings.dart';

class FromCSVSettings extends CSVSettings {
  const FromCSVSettings({
    this.inputFilepath,
    this.urlFile,
    this.outputDir = '',
    this.filePrependName = '',
    this.useJsonExtension = false,
    super.baseIndex,
    super.descriptionIndex,
    super.eol,
    super.delimiter,
  }) : assert(
          urlFile != null || inputFilepath != null,
          '''You must specify an input file, whether is from an url or local path''',
        );

  /// Required if [inputFilepath] is not specified.
  ///
  /// Useful to generate ARB files from URL CSV file.
  final String? urlFile;

  /// Required.
  ///
  /// Specifies the path where CSV file is.
  final String? inputFilepath;

  /// A directory to generate the output ARB files.
  final String outputDir;

  /// Specifies the text to prepend to each ARB file
  ///
  /// Defaults to empty string.
  final String filePrependName;

  /// If true, it will generate `.json` files instead of `.arb`.
  final bool useJsonExtension;
}
