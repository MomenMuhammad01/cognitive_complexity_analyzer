import 'dart:io';

import 'package:args/args.dart';
import 'package:cognitive_complexity_analyzer/analyzer.dart';

/// The main function where package execute .
void main(List<String> arguments) {
  /// Set up the command-line argument parser
  final parser = ArgParser()

    /// Define an options for specifying the target directory
    ..addOption(
      'directory',
      abbr: 'd',
      help: StringsManager.directoryHelpMessage,
    )

    /// Option for maximum allowed complexity, with a default value of 15
    ..addOption(
      'max-complexity',
      abbr: 'm',
      defaultsTo: '15',
      help: StringsManager.maxComplexityHelpMessage,
    ) // Help message for this option
    /// Option for high nesting threshold, with a default value of 3
    ..addOption(
      'high-nesting-threshold',
      abbr: 'n',
      defaultsTo: '3',
      help: StringsManager.highNestingThresholdHelpMessage,
    ) // Help message for this option
    /// Option to show file paths as a tree structure, defaulting to false
    ..addOption(
      'show-paths-as-tree',
      abbr: 's',
      defaultsTo: 'false',
      help: StringsManager.highNestingThresholdHelpMessage,
    ) // Help message for this option
    /// Option to exclude files matching specific patterns
    ..addOption(
      'exclude',
      abbr: 'e',
      help: StringsManager.excludeFilesHelpMessage,
    ) // Help message for this option
    /// Flag for displaying help information
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: StringsManager.helpMessage,
    ); // Help message for this option

  /// Parse the command-line arguments
  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print(StringsManager.argumentsError);
    print(parser.usage);
    return;
  }

  /// If the help flag is set, display the help message and exit
  if (argResults['help']) {
    print(parser.usage);
    return;
  }

  /// Ensure the required 'directory' argument is provided
  if (!argResults.wasParsed('directory')) {
    print(StringsManager.argumentsError);
    print(parser.usage);
    return;
  }

  /// Extract values from the parsed arguments
  var directoryPath = argResults['directory'];
  int maxComplexity = int.parse(argResults['max-complexity']);
  int highNestingThreshold = int.parse(argResults['high-nesting-threshold']);
  bool showPathsAsTree = argResults['show-paths-as-tree'] == 'true';
  List<String> excludePatterns = argResults['exclude']?.split(',') ??
      ['.freezed', '.g']; // Default exclusions

  // Create a Directory object from the specified path
  Directory directory = Directory(directoryPath);
  // Create an AnalysisSettings object with the specified thresholds
  AnalysisSettings settings = AnalysisSettings(
    highNestingLevelThreshold: highNestingThreshold,
    maxCognitiveComplexityScore: maxComplexity,
  );

  // Check if the directory exists
  if (!directory.existsSync()) {
    print(
      StringsManager.directoryNotFound(directoryPath),
    ); // Print an error message if not found
    return;
  }

  /// Get all Dart files within the directory, excluding those matching the patterns
  var dartFiles = _getDartFiles(directory, excludePatterns);

  /// Analyze the collected Dart files and get complexity analysis results
  var results = analyzeAllFiles(dartFiles, settings);

  /// Create a CognitiveComplexityReporter to generate and display the report
  CognitiveComplexityReporter complexityReporter = CognitiveComplexityReporter(
    analyzedFilesCount: dartFiles.length,
    results: results,
    settings: settings,
    showPathsAsTree: showPathsAsTree,
  );
  complexityReporter.generateAndPrintReport();
}

/// Private helper function to retrieve all Dart files within a directory,
/// excluding files that match the given `excludePatterns`.
List<File> _getDartFiles(Directory directory, List<String> excludePatterns) {
  return directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .map((entity) => entity as File)
      .where((file) => !_isExcluded(file, excludePatterns))
      .toList();
}

/// Private helper function to determine if a file should be excluded based on its path
/// and the provided `excludePatterns`.
bool _isExcluded(File file, List<String> excludePatterns) {
  for (var pattern in excludePatterns) {
    if (file.path.contains(pattern)) {
      // Check if the file path contains any of the exclude patterns
      return true; // Exclude the file if a match is found
    }
  }
  return false; // Include the file if no match is found
}
