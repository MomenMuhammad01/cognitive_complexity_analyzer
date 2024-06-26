import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:cognitive_complexity_analyzer/analyzer/analysis_results.dart';
import 'package:cognitive_complexity_analyzer/analyzer/analysis_settings.dart';
import 'package:cognitive_complexity_analyzer/visitor/cognitive_complexity_visitor.dart';

void calculateCognitiveComplexity(
    String code, CognitiveComplexityVisitor visitor) {
  var parseResult = parseString(content: code);
  parseResult.unit.visitChildren(visitor);
}

AnalysisResult processFile(File file, AnalysisSettings settings) {
  var code = file.readAsStringSync();
  var visitor =
      CognitiveComplexityVisitor(threshold: settings.maxCognitiveComplexity);
  calculateCognitiveComplexity(code, visitor);

  return AnalysisResult(
      file.path,
      visitor.calculateComplexityScore(),
      visitor
          .identifyHighComplexitySections(settings.highNestingLevelThreshold));
}

String generateReportContent(List<AnalysisResult> results) {
  var now = DateTime.now();
  var formattedTime = now.toString().substring(11, 16); // Extract time (HH:MM)
  var formattedDate =
      now.toString().substring(0, 10); // Extract date (YYYY-MM-DD)
  var reportContent = StringBuffer();

  reportContent
      .write('Cognitive Complexity Report ($formattedTime - $formattedDate)\n');
  reportContent.write('==============================\n\n');
  if (results.isEmpty) {
    reportContent.write('**No files with high cognitive complexity found!**\n');
  } else {
    for (var result in results) {
      reportContent.write('File: ${result.filePath}\n');
      reportContent.write(
          'ISSUE : Cognitive Complexity is (${result.cognitiveComplexity})\n\n');
    }
  }

  return reportContent.toString();
}

String generateUniqueReportFilename() {
  var now = DateTime.now();
  var formattedDate = now.toString().substring(0, 10); // Extract YYYY-MM-DD
  var formattedTime = now.toString().substring(11, 16); // Extract HH:MM
  return 'cognitive_complexity_report-$formattedDate-$formattedTime.txt';
}

void generateReport(List<AnalysisResult> results) async {
  String filename = generateUniqueReportFilename();
  var file = File(filename);
  try {
    var sink = file.openWrite(); // Use async/await for file operations
    if (results.isEmpty) {
      print('No files with high cognitive complexity found.');
      return; // Exit the function if no issues are found
    }

    sink.write(generateReportContent(results)); // Use generated report content

    await sink.flush(); // Flush data to disk before closing
    sink.close();
    print('==============================');
    print('Report generated at: $filename');
  } catch (e) {
    print('Error generating report: $e');
  }
}
