import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'complexity_point.dart';

class CognitiveComplexityVisitor extends RecursiveAstVisitor<void> {
  final int complexityThreshold;
  List<ComplexityPoint> complexityPoints = [];
  int nestingDepth = 0;

  // Tracks the name of the currently visited function
  String? currentFunctionName;

  CognitiveComplexityVisitor({required this.complexityThreshold});

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Set the current function name
    currentFunctionName = node.name.stringValue;
    super.visitFunctionDeclaration(node);
    currentFunctionName = null; // Reset after processing the function
  }

  @override
  void visitIfStatement(IfStatement node) {
    _increaseComplexityScore(1);
    super.visitIfStatement(node);
    _endComplexityScope();
  }

  @override
  void visitForStatement(ForStatement node) {
    _increaseComplexityScore(2); // Higher base complexity for loops
    super.visitForStatement(node);
    _endComplexityScope();
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _increaseComplexityScore(2); // Higher base complexity for loops
    super.visitWhileStatement(node);
    _endComplexityScope();
  }

  @override
  void visitDoStatement(DoStatement node) {
    _increaseComplexityScore(2); // Higher base complexity for loops
    super.visitDoStatement(node);
    _endComplexityScope();
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _increaseComplexityScore(1); // Base complexity for switch statement
    super.visitSwitchStatement(node);
    _endComplexityScope();
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type == TokenType.AMPERSAND_AMPERSAND ||
        node.operator.type == TokenType.BAR_BAR) {
      _increaseComplexityScore(1); // Complexity for logical operators
    }
    super.visitBinaryExpression(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _increaseComplexityScore(1); // Base complexity for conditional expression
    super.visitConditionalExpression(node);
    _endComplexityScope();
  }

  @override
  void visitCatchClause(CatchClause node) {
    _increaseComplexityScore(1); // Complexity for catch clauses
    super.visitCatchClause(node);
    _endComplexityScope();
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Check if the method being called is the same as the current function (indicating recursion)
    if (node.methodName.name == currentFunctionName) {
      _increaseComplexityScore(2); // Add complexity for recursion
    }
    super.visitMethodInvocation(node);
  }

  // Adds a complexity point and increments the nesting depth
  void _increaseComplexityScore(int baseComplexity, {int weight = 1}) {
    nestingDepth++;
    complexityPoints.add(ComplexityPoint(
        complexity: baseComplexity + nestingDepth * weight,
        nestingLevel: nestingDepth));
  }

  // Ends a complexity scope by decrementing the nesting depth
  void _endComplexityScope() {
    nestingDepth--;
  }

  List<String> identifyHighComplexitySections(int nestingThreshold) {
    List<String> highComplexitySections = [];
    for (var point in complexityPoints) {
      if (point.complexity > complexityThreshold &&
          point.nestingLevel > nestingThreshold) {
        highComplexitySections.add('Line ${point.nestingLevel}');
      }
    }
    return highComplexitySections;
  }

  int calculateTotalComplexityScore() {
    return complexityPoints.fold<int>(
        0, (sum, point) => sum + point.complexity);
  }
}
