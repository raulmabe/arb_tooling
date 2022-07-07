abstract class CSVConfig {
  const CSVConfig({
    this.delimiter = ',',
    this.eol = '\r\n',
    this.descriptionIndex = 1,
    this.baseIndex = 2,
  });

  /// A delimiter to separate columns in the input CSV file.
  /// Defaults to `,`.
  final String delimiter;

  /// The description column index.
  /// Defaults to `1`.
  final int descriptionIndex;

  /// The column index of the base language in the input CSV file.
  /// Defaults to `2`.
  final int baseIndex;

  /// Default to `\r\n`.
  final String eol;
}
