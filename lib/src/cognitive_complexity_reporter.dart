import 'dart:io';

import 'package:cognitive_complexity_analyzer/src/models/analysis_results.dart';
import 'package:cognitive_complexity_analyzer/src/models/analysis_settings.dart';
import 'package:cognitive_complexity_analyzer/src/util/strings_manager.dart';

/// Class responsible for generating and presenting reports on cognitive complexity analysis results.
class CognitiveComplexityReporter {
  List<AnalysisResult> results; // List of analysis results for each file
  AnalysisSettings settings; // Settings used for the analysis
  int analyzedFilesCount; // Total number of files analyzed
  bool showPathsAsTree; // Whether to display file paths in a tree structure
  late double
      normalComplexityPercentage; // Percentage of files with normal complexity (calculated)

  CognitiveComplexityReporter({
    required this.results,
    required this.settings,
    required this.showPathsAsTree,
    required this.analyzedFilesCount,
  }) {
    normalComplexityPercentage = _calculateNormalComplexityPercentage(
      results.length,
      analyzedFilesCount,
    );
  }

  /// Private helper method to calculate the percentage of files with normal complexity.
  double _calculateNormalComplexityPercentage(
    int highComplexityFiles,
    int totalFiles,
  ) {
    return ((totalFiles - highComplexityFiles) / totalFiles) * 100;
  }

  /// Generates and prints the complexity report to the console.
  /// If no high complexity files are found, prints a message indicating so.
  /// Otherwise, calls `_createReport` to generate the report file and prints a summary to the console.
  void generateAndPrintReport() async {
    // Print the report summary to the console
    print(StringsManager.consoleTitle);
    print(StringsManager.divider);
    print(StringsManager.numberOfProcessedFiles(analyzedFilesCount));
    print(StringsManager.filesWithHighComplexity(results.length));
    print(
        StringsManager.normalComplexityPercentage(normalComplexityPercentage));
    _createReport();
  }

  /// Private method to create the report file and write the report content to it.
  /// Handles potential errors during file creation and writing.
  void _createReport() {
    print('Starting _createReport');
    final directory = Directory(StringsManager.reportDirectoryPath);

    if (directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    var reportFile = File(StringsManager.generatedFileName);

    try {
      var openFile = reportFile.openSync(mode: FileMode.write);
      try {
        openFile.writeString(
          _generateReportContent(), // Write the report content
        );
        openFile.flush();
      } finally {
        print(StringsManager.divider);
        print(
            StringsManager.reportGeneratedAt(StringsManager.generatedFileName));
        openFile.close();
      }
    } catch (error) {
      print('Error during report creation: $error');
    }
  }

  /// Private method to generate the content of the report as a string.
  /// Includes a header, summary statistics, and details for each file with high complexity.
  String _generateReportContent() {
    var reportContentBuffer = StringBuffer();
    // Build the report content
    reportContentBuffer.writeln(StringsManager.cognitiveComplexityReport);
    reportContentBuffer.writeln(StringsManager.divider);
    // Add analysis summary

    reportContentBuffer.writeln(
        StringsManager.normalComplexityPercentage(normalComplexityPercentage));
    reportContentBuffer
        .writeln(StringsManager.numberOfProcessedFiles(analyzedFilesCount));
    reportContentBuffer
        .writeln(StringsManager.filesWithHighComplexity(results.length));
    reportContentBuffer.writeln(StringsManager.divider);
    if (results.isNotEmpty) {
      // Iterate through each analysis result and add its details to the report
      for (var result in results) {
        if (showPathsAsTree) {
          reportContentBuffer.writeln(StringsManager.filePathTitle);
          reportContentBuffer
              .writeln(_generateFileTreeStructure(result.filePath));
        } else {
          reportContentBuffer.writeln(StringsManager.filePath(result.filePath));
        }
        reportContentBuffer.writeln(
            '${StringsManager.cognitiveComplexityResults(result.cognitiveComplexityScore)}');
        if (result.highComplexityLines.isNotEmpty) {
          reportContentBuffer.writeln(
              '${StringsManager.linesWithHighNesting(settings.highNestingLevelThreshold)}');
        }
        reportContentBuffer.writeln(StringsManager.divider);
      }
    } else {
      print(StringsManager.noHighCognitiveComplexityFound);
    }
    return reportContentBuffer.toString(); // Return the final report content
  }

  /// Private static helper method to generate a tree-like structure representing a file path.
  /// This is used to display the file paths in a more visually organized way when the `showPathsAsTree` option is enabled.
  ///
  ///
  /// Returns:
  /// - A formatted string representing the file path in a tree-like structure.
  static String _generateFileTreeStructure(String filePath) {
    var parts = filePath
        .split(Platform.pathSeparator); // Split the path into its components
    var buffer = StringBuffer(); // String buffer to build the output
    var prefixes = <String>[]; // List to store prefixes for each level

    // Iterate through each part of the path
    for (var i = 0; i < parts.length; i++) {
      var isLast =
          i == parts.length - 1; // Check if it's the last part (file name)
      var prefix = prefixes.join(); // Get the prefix for the current level

      // Add the current part to the buffer with the appropriate prefix and connector (├── or └──)
      buffer.writeln('$prefix${isLast ? '└── ' : '├── '}${parts[i]}');

      if (!isLast) {
        // If it's not the last part, add the appropriate prefix for the next level ( │   or     )
        prefixes.add(isLast ? '    ' : '│   ');
      }
    }

    return buffer.toString(); // Return the final formatted string
  }
}
