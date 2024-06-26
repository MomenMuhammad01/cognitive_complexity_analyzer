class AnalysisSettings {
  final int maxCognitiveComplexity;
  final int highNestingLevelThreshold;

  AnalysisSettings({
    this.maxCognitiveComplexity = 15,
    this.highNestingLevelThreshold = 3,
  });
}
