class AnalysisResult {
  String filePath;
  int cognitiveComplexity;
  List<String> highComplexityLines;

  AnalysisResult(
    this.filePath,
    this.cognitiveComplexity,
    this.highComplexityLines,
  );
}
