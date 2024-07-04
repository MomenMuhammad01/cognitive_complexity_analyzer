class StringsManager {
  static String consoleTitle = "Cognitive Complexity Report:";
  static String generatedFileName(String date, String time) =>
      'cognitive_complexity_report-$date-$time.txt';

  static const String argumentsError =
      'Error: Please provide a directory path and (optional) settings.';

  static String handlingError(dynamic error) => "Error: ${error.toString()}";

  static String directoryNotFound(String directoryPath) =>
      'Directory not found: $directoryPath';

  static String cognitiveComplexityReport(String time, String date) =>
      'Cognitive Complexity Report ($time - $date)\n';

  static const String noHighCognitiveComplexityFound =
      'No files with high cognitive complexity found.';

  static const String highCognitiveComplexityDetected =
      'High Cognitive Complexity Detected:\n';

  static const String filePath = 'File Path: ';

  static String cognitiveComplexityResults(final int complexityScore) =>
      'ISSUE : Cognitive Complexity: $complexityScore';

  static const String divider = "==============================";

  static String linesWithHighNesting(int highestAllowedNesting) =>
      "ISSUE : High Nesting detected (> $highestAllowedNesting):";

  static String numberOfProcessedFiles(int filesProcessed) =>
      'Files processed: $filesProcessed';

  static String filesWithHighComplexity(int filesCount) =>
      'Files with high cognitive complexity: $filesCount';

  static String reportGeneratedAt(String fileName) =>
      'Report generated at: $fileName';

  static const String directoryHelpMessage =
      'The directory containing Dart files to analyze.';

  static const String maxComplexityHelpMessage =
      "Maximum cognitive complexity score a file shouldn't pass.";

  static const String highNestingThresholdHelpMessage =
      "Maximum nesting level allowed for a function.";

  static const String helpMessage = 'Show usage information.';
}
