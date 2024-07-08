import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:cognitive_complexity_analyzer/analyzer.dart';
import 'package:cognitive_complexity_analyzer/src/cognitive_complexity_visitor.dart';

List<AnalysisResult> analyzeAllFiles(
    List<File> dartFiles, AnalysisSettings settings) {
  List<AnalysisResult> results = [];
  for (var file in dartFiles) {
    var result = analyzeFile(file, settings);
    if (result.cognitiveComplexityScore >
        settings.maxCognitiveComplexityScore) {
      results.add(result);
    }
  }
  return results;
}

AnalysisResult analyzeFile(File file, AnalysisSettings settings) {
  var codeContent = file.readAsStringSync();
  var complexityVisitor = CognitiveComplexityVisitor(
    complexityThreshold: settings.maxCognitiveComplexityScore,
    maxNestingLevel: settings.highNestingLevelThreshold,
  );
  calculateCognitiveComplexity(codeContent, complexityVisitor);

  return AnalysisResult(
    file.path,
    complexityVisitor.getTotalComplexityScore(),
    complexityVisitor.getHighComplexitySections(
      settings.highNestingLevelThreshold,
    ),
  );
}

void calculateCognitiveComplexity(
    String code, CognitiveComplexityVisitor visitor) {
  var parsedResult = parseString(content: code);
  parsedResult.unit.visitChildren(visitor);
}
