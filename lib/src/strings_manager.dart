class StringsManager {
  static generatedFileName(String date, String time) =>
      'cognitive_complexity_report-$date-$time.txt';
  static const argumentsError =
      'Error: Please provide a directory path and (optional) settings.';
  static handlingError(dynamic error) => "Error: ${error.toString()}";
  static directoryNotFound(String directoryPath) =>
      'Directory not found: $directoryPath';
  static cognitiveComplexityReport(String time, String date) =>
      'Cognitive Complexity Report ($time - $date)\n';
  static const noHighCognitiveComplexityFound =
      'No files with high cognitive complexity found.';
  static const highCognitiveComplexityDetected =
      'High Cognitive Complexity Detected:\n';
  static filePath(String filePath) => 'File: $filePath \n';
  static cognitiveComplexityResults(final int complexityScore) =>
      'ISSUE : Cognitive Complexity: $complexityScore\n\n';
  static const divider = "==============================";

  static linesWithHighNesting(int highestAllowedNesting) =>
      "Lines with High Nesting (>$highestAllowedNesting):}";
  static numberOfProcessedFiles(int filesProcessed) =>
      'Files processed: $filesProcessed';
  static filesWithHighComplexity(int filesCount) =>
      'Files with high cognitive complexity: $filesCount';
  static reportGeneratedAt(String fileName) => 'Report generated at: $fileName';
}
