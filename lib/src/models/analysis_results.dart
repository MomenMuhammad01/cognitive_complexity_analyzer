class AnalysisResult {
  String filePath;
  int cognitiveComplexityScore;
  List<String> highComplexityLines;

  AnalysisResult(
    this.filePath,
    this.cognitiveComplexityScore,
    this.highComplexityLines,
  );
}
