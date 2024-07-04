import 'dart:io';

import 'package:args/args.dart';
import 'package:cognitive_complexity_analyzer/analyzer.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('directory',
        abbr: 'd', help: StringsManager.directoryHelpMessage)
    ..addOption('max-complexity',
        abbr: 'm',
        defaultsTo: '15',
        help: StringsManager.maxComplexityHelpMessage)
    ..addOption('high-nesting-threshold',
        abbr: 'n',
        defaultsTo: '3',
        help: StringsManager.highNestingThresholdHelpMessage)
    ..addFlag('help',
        abbr: 'h', negatable: false, help: StringsManager.helpMessage);

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print(StringsManager.argumentsError);
    print(parser.usage);
    return;
  }

  if (argResults['help']) {
    print(parser.usage);
    return;
  }

  if (!argResults.wasParsed('directory')) {
    print(StringsManager.argumentsError);
    print(parser.usage);
    return;
  }

  var directoryPath = argResults['directory'];
  int maxComplexity = int.parse(argResults['max-complexity']);
  int highNestingThreshold = int.parse(argResults['high-nesting-threshold']);

  var directory = Directory(directoryPath);
  var settings = AnalysisSettings(
    highNestingLevelThreshold: highNestingThreshold,
    maxCognitiveComplexityScore: maxComplexity,
  ); // Initialize with settings from arguments or defaults

  if (!directory.existsSync()) {
    print(StringsManager.directoryNotFound(directoryPath));
    return;
  }

  var dartFiles = _getDartFiles(directory);
  var results = analyzeAllFiles(dartFiles, settings);

  generateAndPrintReport(results, settings, dartFiles.length);
}

List<File> _getDartFiles(Directory directory) {
  return directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .map((entity) => entity as File)
      .toList();
}
