library cognitive_complexity_analyzer;

import 'dart:io';

import 'package:cognitive_complexity_analyzer/analyzer.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print(StringsManager.argumentsError);
    return;
  }

  var directoryPath = arguments[0];
  int? maxComplexity;
  int? highNestingThreshold;

  // Parse optional settings arguments (if any)
  if (arguments.length >= 3) {
    try {
      maxComplexity = int.parse(arguments[1]);
      highNestingThreshold = int.parse(arguments[2]);
    } catch (error) {
      print(StringsManager.handlingError(error));

      return;
    }
  }

  var directory = Directory(directoryPath);
  var settings = AnalysisSettings(
    highNestingLevelThreshold: highNestingThreshold ?? 3,
    maxCognitiveComplexity: maxComplexity ?? 15,
  ); // Initialize with default settings

  if (!directory.existsSync()) {
    print(StringsManager.directoryNotFound(directoryPath));
    return;
  }

  var dartFiles = _getDartFiles(directory);
  var results = _analyzeFiles(dartFiles, settings);

  _generateAndPrintReport(results, settings, dartFiles.length);
}

List<File> _getDartFiles(Directory directory) {
  return directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .map((entity) => entity as File)
      .toList();
}

List<AnalysisResult> _analyzeFiles(
    List<File> dartFiles, AnalysisSettings settings) {
  List<AnalysisResult> results = [];
  for (var file in dartFiles) {
    var result = processFile(file, settings);
    if (result.cognitiveComplexity > settings.maxCognitiveComplexity) {
      results.add(result);
    }
  }
  return results;
}

void _generateAndPrintReport(List<AnalysisResult> results,
    AnalysisSettings settings, int filesProcessed) {
  generateReport(results);

  if (results.isEmpty) {
    print(StringsManager.noHighCognitiveComplexityFound);
  } else {
    print(StringsManager.highCognitiveComplexityDetected);
    print(StringsManager.divider);
    for (var result in results) {
      print(StringsManager.filePath(result.filePath));
      print(StringsManager.cognitiveComplexityResults(
          result.cognitiveComplexity));

      if (result.highComplexityLines.isNotEmpty) {
        print(StringsManager.linesWithHighNesting(
            settings.highNestingLevelThreshold));

        for (var line in result.highComplexityLines) {
          print('- $line');
        }
      }
      print(StringsManager.divider);
    }
  }
  print(StringsManager.numberOfProcessedFiles(filesProcessed));
  print(StringsManager.filesWithHighComplexity(results.length));
}
