import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'complexity_point.dart';

class CognitiveComplexityVisitor extends RecursiveAstVisitor<void> {
  final int threshold;
  List<ComplexityPoint> complexityPoints = [];
  int currentNestingLevel = 0;

  // Keeps track of the current function being visited
  String? currentFunctionName;

  CognitiveComplexityVisitor({required this.threshold});

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Save the current function name
    currentFunctionName = node.name.stringValue;
    super.visitFunctionDeclaration(node);
    currentFunctionName = null; // Reset after processing the function
  }

  @override
  void visitIfStatement(IfStatement node) {
    _increaseComplexity(1);
    super.visitIfStatement(node);
    _decreaseComplexity();
  }

  @override
  void visitForStatement(ForStatement node) {
    _increaseComplexity(2); // Higher base complexity for loops
    super.visitForStatement(node);
    _decreaseComplexity();
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _increaseComplexity(2); // Higher base complexity for loops
    super.visitWhileStatement(node);
    _decreaseComplexity();
  }

  @override
  void visitDoStatement(DoStatement node) {
    _increaseComplexity(2); // Higher base complexity for loops
    super.visitDoStatement(node);
    _decreaseComplexity();
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _increaseComplexity(1); // Base complexity for switch statement
    super.visitSwitchStatement(node);
    _decreaseComplexity();
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type == TokenType.AMPERSAND_AMPERSAND ||
        node.operator.type == TokenType.BAR_BAR) {
      _increaseComplexity(1); // Complexity for logical operators
    }
    super.visitBinaryExpression(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _increaseComplexity(1); // Base complexity for conditional expression
    super.visitConditionalExpression(node);
    _decreaseComplexity();
  }

  @override
  void visitCatchClause(CatchClause node) {
    _increaseComplexity(1); // Complexity for catch clauses
    super.visitCatchClause(node);
    _decreaseComplexity();
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Check if the method being called is the same as the current function (indicating recursion)
    if (node.methodName.name == currentFunctionName) {
      _increaseComplexity(2); // Add complexity for recursion
    }
    super.visitMethodInvocation(node);
  }

  void _increaseComplexity(int baseComplexity, {int weight = 1}) {
    currentNestingLevel++;
    complexityPoints.add(ComplexityPoint(
        complexity: baseComplexity + currentNestingLevel * weight,
        nestingLevel: currentNestingLevel));
  }

  void _decreaseComplexity() {
    currentNestingLevel--;
  }

  int calculateComplexityScore() {
    return complexityPoints.fold<int>(
        0, (sum, point) => sum + point.complexity);
  }

  List<String> identifyHighComplexitySections(int lineNumberThreshold) {
    List<String> highComplexitySections = [];
    for (var point in complexityPoints) {
      if (point.complexity > threshold &&
          point.nestingLevel > lineNumberThreshold) {
        highComplexitySections.add('Line ${point.nestingLevel}');
      }
    }
    return highComplexitySections;
  }
}
