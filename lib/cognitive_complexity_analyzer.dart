library cognitive_complexity_analyzer;

import 'dart:io';

import 'analyzer/analysis_results.dart';
import 'analyzer/analysis_settings.dart';
import 'processor/file_processor.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Error: Please provide a directory path as an argument.');
    return;
  }

  var directoryPath = arguments[0];
  var directory = Directory(directoryPath);
  var settings = AnalysisSettings(); // Initialize with default settings

  if (!directory.existsSync()) {
    print('Directory not found: $directoryPath');
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
    print('No files with high cognitive complexity found.');
  } else {
    print('High Cognitive Complexity Detected:');
    print('==============================');
    for (var result in results) {
      print('File: ${result.filePath}');
      print('Cognitive Complexity: ${result.cognitiveComplexity}');
      if (result.highComplexityLines.isNotEmpty) {
        print(
            'Lines with High Nesting (>${settings.highNestingLevelThreshold}):');
        for (var line in result.highComplexityLines) {
          print('- $line');
        }
      }
      print('==============================');
    }
  }

  print('Files processed: $filesProcessed');
  print('Files with high cognitive complexity: ${results.length}');
}
