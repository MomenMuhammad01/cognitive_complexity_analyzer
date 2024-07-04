import 'dart:io';

import 'package:cognitive_complexity_analyzer/src/analysis_results.dart';
import 'package:cognitive_complexity_analyzer/src/analysis_settings.dart';
import 'package:cognitive_complexity_analyzer/src/strings_manager.dart';

void generateAndPrintReport(List<AnalysisResult> results,
    AnalysisSettings settings, int filesProcessed) {
  if (results.isEmpty) {
    print(StringsManager.noHighCognitiveComplexityFound);
    return;
  }
  _createReport(results, settings);
  print(StringsManager.consoleTitle);
  print(StringsManager.divider);
  print(StringsManager.numberOfProcessedFiles(filesProcessed));
  print(StringsManager.filesWithHighComplexity(results.length));
}

void _createReport(
  List<AnalysisResult> results,
  AnalysisSettings settings,
) async {
  String reportFilename = _generateReportFilename();
  var reportFile = File(reportFilename);
  try {
    var reportFileSink = await reportFile.openWrite();
    if (results.isEmpty) {
      print(StringsManager.noHighCognitiveComplexityFound);
      return; // Exit the function if no issues are found
    }
    reportFileSink.write(
      _generateReportContent(
        results,
        settings,
      ),
    ); // Use generated report content

    await reportFileSink.flush(); // Flush data to disk before closing
    reportFileSink.close();
    print(StringsManager.divider);
    print(StringsManager.reportGeneratedAt(reportFilename));
  } catch (error) {
    print(StringsManager.handlingError(error));
  }
}

String _generateReportFilename() {
  var currentTime = DateTime.now();
  var date = currentTime.toString().substring(0, 10); // Extract YYYY-MM-DD
  var time = currentTime.toString().substring(11, 16); // Extract HH:MM
  return StringsManager.generatedFileName(date, time);
}

String _generateReportContent(
    List<AnalysisResult> results, AnalysisSettings settings) {
  var currentTime = DateTime.now();
  var date =
      currentTime.toString().substring(0, 10); // Extract date (YYYY-MM-DD)
  var time = currentTime.toString().substring(11, 16); // Extract time (HH:MM)
  var reportContentBuffer = StringBuffer();

  reportContentBuffer.writeln('Cognitive Complexity Report ($time - $date)\n');
  reportContentBuffer.writeln(StringsManager.divider);
  for (var result in results) {
    reportContentBuffer.writeln(StringsManager.filePath);
    reportContentBuffer.writeln(_generateFileTreeStructure(result.filePath));
    reportContentBuffer.writeln(
        '${StringsManager.cognitiveComplexityResults(result.cognitiveComplexityScore)}');
    if (result.highComplexityLines.isNotEmpty) {
      // Print notice for high nesting issues detected
      reportContentBuffer.writeln(
          '${StringsManager.linesWithHighNesting(settings.highNestingLevelThreshold)}');
    }
    reportContentBuffer.writeln(StringsManager.divider);
  }

  return reportContentBuffer.toString();
}

String _generateFileTreeStructure(String filePath) {
  var parts = filePath.split(Platform.pathSeparator);
  var buffer = StringBuffer();
  var prefixes = <String>[];

  for (var i = 0; i < parts.length; i++) {
    var isLast = i == parts.length - 1;
    var prefix = prefixes.join();

    buffer.writeln('$prefix${isLast ? '└── ' : '├── '}${parts[i]}');

    if (!isLast) {
      prefixes.add(isLast ? '    ' : '│   ');
    }
  }

  return buffer.toString();
}
