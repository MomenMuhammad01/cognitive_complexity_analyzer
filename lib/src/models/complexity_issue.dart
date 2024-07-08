import 'package:analyzer/dart/ast/token.dart';

class ComplexityIssue {
  final int complexity;
  final Token token;

  ComplexityIssue({
    required this.complexity,
    required this.token,
  });
}
