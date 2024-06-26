import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:cognitive_complexity_analyzer/analyzer.dart';

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
    visitor.identifyHighComplexitySections(settings.highNestingLevelThreshold),
  );
}

String generateReportContent(List<AnalysisResult> results) {
  var now = DateTime.now();
  var formattedTime = now.toString().substring(11, 16); // Extract time (HH:MM)
  var formattedDate =
      now.toString().substring(0, 10); // Extract date (YYYY-MM-DD)
  var reportContent = StringBuffer();

  reportContent.write(
    StringsManager.cognitiveComplexityReport(
      formattedDate,
      formattedTime,
    ),
  );
  reportContent.write('${StringsManager.divider}\n\n');
  if (results.isEmpty) {
    reportContent.write(StringsManager.highCognitiveComplexityDetected);
  } else {
    for (var result in results) {
      reportContent.write(StringsManager.filePath(result.filePath));
      reportContent.write(StringsManager.cognitiveComplexityResults(
        result.cognitiveComplexity,
      ));
    }
  }

  return reportContent.toString();
}

String generateUniqueReportFilename() {
  var now = DateTime.now();
  var formattedDate = now.toString().substring(0, 10); // Extract YYYY-MM-DD
  var formattedTime = now.toString().substring(11, 16); // Extract HH:MM
  return StringsManager.generatedFileName(formattedDate, formattedTime);
}

void generateReport(List<AnalysisResult> results) async {
  String filename = generateUniqueReportFilename();
  var file = File(filename);
  try {
    var sink = file.openWrite(); // Use async/await for file operations
    if (results.isEmpty) {
      print(StringsManager.noHighCognitiveComplexityFound);
      return; // Exit the function if no issues are found
    }

    sink.write(generateReportContent(results)); // Use generated report content

    await sink.flush(); // Flush data to disk before closing
    sink.close();
    print(StringsManager.divider);

    print(StringsManager.reportGeneratedAt(filename));
  } catch (e) {
    print(StringsManager.handlingError(e));
  }
}
