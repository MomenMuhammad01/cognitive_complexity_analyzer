import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:cognitive_complexity_analyzer/src/cognitive_complexity_calculator.dart';

/// A visitor that calculates the cognitive complexity of Dart code.
/// It traverses the Abstract Syntax Tree (AST) and uses a ComplexityCalculator
/// to track and assess complexity based on the Cognitive Complexity model.
class CognitiveComplexityVisitor extends RecursiveAstVisitor<void> {
  /// Threshold for identifying high-complexity code sections.
  final int complexityThreshold;

  /// Maximum allowed nesting level for code structures.
  final int maxNestingLevel;

  /// The calculator responsible for tracking and assessing complexity.
  final CognitiveComplexityCalculator complexityCalculator;

  /// Constructor to initialize the visitor with complexity thresholds.
  CognitiveComplexityVisitor({
    required this.complexityThreshold,
    required this.maxNestingLevel,
  }) : complexityCalculator = CognitiveComplexityCalculator(
          complexityThreshold: complexityThreshold,
          maxNestingLevel: maxNestingLevel,
        );

  /// Visits a FunctionExpression node.
  /// - Informs the calculator that a new function scope is being entered.
  /// - Recursively visits the body of the function to assess its complexity.
  /// - Informs the calculator that the function scope is being exited.
  @override
  void visitFunctionExpression(FunctionExpression node) {
    complexityCalculator
        .enterFunctionNode(node); // Notify calculator of function entry
    super.visitFunctionExpression(node); // Traverse the function body
    complexityCalculator
        .exitFunctionNode(node); // Notify calculator of function exit
  }

  /// Visits a FunctionDeclaration node.
  /// - Performs the same actions as visitFunctionExpression
  /// both nodes represent functions but this represents function's declaration.
  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    complexityCalculator.enterFunctionNode(node);
    super.visitFunctionDeclaration(node);
    complexityCalculator.exitFunctionNode(node);
  }

  /// Visits a Block node.
  /// - Checks if entering this block increases the nesting depth, and updates the calculator if needed.
  /// - Continues traversal by visiting all statements within the block.
  @override
  void visitBlock(Block node) {
    complexityCalculator.increaseNestingDepthIfNeeded(node);
    super.visitBlock(node); // Recursively visit statements within the block
  }

  /// Visits an IfStatement node.
  /// - Increments structural complexity due to the conditional branching.
  /// - Checks and increases nesting depth if needed.
  /// - Visits the 'then' block of the if statement.
  /// - If there's an 'else' statement, increments hybrid complexity and visits the 'else' block,
  ///   further increasing nesting depth only if it's not another 'if' statement (to avoid double-counting).
  @override
  void visitIfStatement(IfStatement node) {
    complexityCalculator.addStructuralComplexity(1); // Increment for 'if'
    complexityCalculator.increaseNestingDepthIfNeeded(node);
    super.visitIfStatement(node);
    // Handle 'else if' and 'else'
    if (node.elseStatement != null) {
      complexityCalculator.addHybridComplexity(1); // Hybrid for 'else'
      if (node.elseStatement is! IfStatement) {
        // Only increase nesting for plain 'else'
        complexityCalculator
            .increaseNestingDepthIfNeeded(node.elseStatement as AstNode);
      }
    }
  }

  /// Visits a WhileStatement node (while loop).
  /// - Increases structural complexity due to the loop structure.
  /// - Checks and increases nesting depth if needed.
  /// - Continues traversal by visiting the body of the while loop.
  @override
  void visitWhileStatement(WhileStatement node) {
    complexityCalculator.addStructuralComplexity(1); // Increase Complexity
    complexityCalculator
        .increaseNestingDepthIfNeeded(node); // Increase Nesting if needed
    super.visitWhileStatement(node); // Visit loop body
  }

  /// Visits a ForStatement node (for loop).
  /// - Increases structural complexity due to the loop structure.
  /// - Checks and increases nesting depth if needed.
  /// - Continues traversal by visiting the body of the for loop.
  @override
  void visitForStatement(ForStatement node) {
    complexityCalculator.addStructuralComplexity(1); // Increase Complexity
    complexityCalculator
        .increaseNestingDepthIfNeeded(node); // Increase Nesting if needed
    super.visitForStatement(node); // Visit loop body
  }

  /// Visits a DoStatement node (do-while loop).
  /// - Increases structural complexity due to the loop structure.
  /// - Checks and increases nesting depth if needed.
  /// - Continues traversal by visiting the body of the do-while loop.
  @override
  void visitDoStatement(DoStatement node) {
    complexityCalculator.addStructuralComplexity(1); // Increase Complexity
    complexityCalculator
        .increaseNestingDepthIfNeeded(node); // Increase Nesting if needed
    super.visitDoStatement(node); // Visit loop body
  }

  /// Visits a ContinueStatement node.
  /// - If the continue statement is labeled (has a label like 'outerLoop:'), it increases fundamental
  ///   complexity, as labeled continues introduce additional control flow paths.
  /// - Otherwise, it's an unlabeled continue, and its complexity is handled by the enclosing loop.
  @override
  void visitContinueStatement(ContinueStatement node) {
    if (node.label != null) {
      complexityCalculator.addFundamentalComplexity(1);
    }
    super.visitContinueStatement(node);
  }

  /// Visits a SwitchStatement node (switch-case).
  /// - Increases structural complexity due to the multiple branching possibilities.
  /// - Checks and increases nesting depth if needed.
  /// - Continues traversal by visiting all the members (cases) within the switch statement.
  @override
  void visitSwitchStatement(SwitchStatement node) {
    complexityCalculator.addStructuralComplexity(1); // Increase Complexity
    complexityCalculator
        .increaseNestingDepthIfNeeded(node); // Increase Nesting if needed
    super.visitSwitchStatement(node); // visit switch block
  }

  /// Visits a CatchClause node (catch block in a try-catch).
  /// - Increases structural complexity as it represents an alternative code path.
  /// - Checks and increases nesting depth if needed.
  /// - Continues traversal by visiting the body of the catch clause.
  @override
  void visitCatchClause(CatchClause node) {
    complexityCalculator.addStructuralComplexity(1); // Increase Complexity
    complexityCalculator
        .increaseNestingDepthIfNeeded(node); // Increase Nesting if needed
    super.visitCatchClause(node); // visit catch block
  }

  /// Visits a TryStatement node (try-catch-finally block).
  /// - Ignores the 'try' block itself (complexity is calculated in its child nodes).
  /// - Visits each CatchClause within the try statement.
  /// - Visits the 'finally' block, if present.
  @override
  void visitTryStatement(TryStatement node) {
    node.body.accept(this); // Analyze the 'try' block's body
    for (var catchClause in node.catchClauses) {
      catchClause.accept(this); // Analyze each 'catch' clause
    }
    node.finallyBlock?.accept(this); // Analyze the 'finally' block (if present)
  }

  /// Visits a ConditionalExpression node (ternary operator ?:).
  /// - Increases structural complexity due to the conditional branching.
  /// - Checks and increases nesting depth if needed.
  /// - Continues traversal by visiting the condition, thenExpression, and elseExpression.
  @override
  void visitConditionalExpression(ConditionalExpression node) {
    complexityCalculator.addStructuralComplexity(1); // Increase Complexity
    complexityCalculator
        .increaseNestingDepthIfNeeded(node); // Increase Nesting if needed
    super.visitConditionalExpression(node); // Visit all parts of the expression
  }

  /// Visits a BinaryExpression node (e.g., arithmetic operations, comparisons, logical AND/OR).
  /// - If the binary expression involves logical operators (&& or ||), it calls the
  ///   `processLogicalExpression` method on the `complexityCalculator` to handle the complexity
  ///   associated with logical sequences.
  /// - If the binary expression is a null-coalescing operator (??), it's ignored, as it doesn't contribute
  ///   to cognitive complexity.
  /// - Otherwise, it proceeds to recursively visit the left and right operands of the binary expression.
  @override
  void visitBinaryExpression(BinaryExpression node) {
    // Check for logical AND
    // Check for logical OR
    if (node.operator.type == TokenType.AMPERSAND_AMPERSAND ||
        node.operator.type == TokenType.BAR_BAR) {
      complexityCalculator.processLogicalExpression(
          node, this); // Increment for logical sequences
    } else if (node.operator.type == TokenType.QUESTION_QUESTION) {
      // Ignore null-coalescing operator
    }
    super.visitBinaryExpression(node);
  }

  /// Visits a MethodInvocation node (a method call).
  /// - Delegates the handling of method invocations to the `complexityCalculator`.
  ///   This is where recursion detection is performed (if the method calls itself).
  /// - Continues traversal by visiting the arguments passed to the method.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    complexityCalculator.processMethodInvocation(node);
    super.visitMethodInvocation(node);
  }

  /// Visits a BreakStatement node.
  /// - If the break statement is labeled (has a label like 'outerLoop:'), it increases fundamental
  ///   complexity, as labeled breaks introduce additional control flow paths.
  /// - Otherwise, it's an unlabeled break, and its complexity is handled by the enclosing loop.
  @override
  void visitBreakStatement(BreakStatement node) {
    if (node.label != null) {
      // Check if it's a labeled break
      complexityCalculator
          .addFundamentalComplexity(1); // Increase complexity for labeled break
    }
    super.visitBreakStatement(node); // Continue traversal
  }

  /// Visits a ReturnStatement node.
  /// - Ignores early returns as they don't affect cognitive complexity in this model.
  ///   The complexity of the returned value is already accounted for in its own subtree.
  @override
  void visitReturnStatement(ReturnStatement node) {
    // Ignore early returns
  }

  /// Retrieves sections of code with high complexity based on a nesting threshold.
  List<String> getHighComplexitySections(int nestingThreshold) {
    return complexityCalculator.getHighComplexitySections(nestingThreshold);
  }

  /// Gets the total calculated complexity score.
  int getTotalComplexityScore() {
    return complexityCalculator.totalComplexityScore;
  }

  /// Gets a list of nodes with nesting levels exceeding the maximum allowed.
  List<String> getHighNestingLevelNodes() {
    return complexityCalculator.highNestingLevelNodesList;
  }
}
