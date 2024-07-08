import 'package:analyzer/dart/ast/ast.dart';
import 'package:cognitive_complexity_analyzer/src/models/complexity_point.dart';

class SecondLevelFunction {
  final AstNode node;
  final AstNode? parent;
  final List<ComplexityPoint> complexityIfThisSecondaryIsTopLevel;
  final List<ComplexityPoint> complexityIfNested;

  SecondLevelFunction({
    required this.node,
    required this.parent,
    required this.complexityIfThisSecondaryIsTopLevel,
    required this.complexityIfNested,
  });
}
