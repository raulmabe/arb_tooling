import 'package:arb_tooling/src/config/csv_config.dart';

class ToCSVConfig extends CSVConfig {
  const ToCSVConfig({
    this.inputDir = '',
    this.outputDir = '',
    this.name = 'translations',
    super.baseIndex,
    super.descriptionIndex,
    super.eol,
    super.delimiter,
  });

  /// Required.
  ///
  /// Specifies the directory from where ARB files are going to be parsed.
  final String inputDir;

  /// A directory to generate the output CSV file.
  final String outputDir;

  /// Specifies the name of the CSV file that'll be generated.
  ///
  /// Defaults to `translations`
  final String name;
}
