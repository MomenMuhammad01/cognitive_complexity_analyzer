import 'package:analyzer/dart/ast/ast.dart';
import 'package:cognitive_complexity_analyzer/src/cognitive_complexity_visitor.dart';
import 'package:cognitive_complexity_analyzer/src/models/complexity_issue.dart';
import 'package:cognitive_complexity_analyzer/src/models/complexity_point.dart';
import 'package:cognitive_complexity_analyzer/src/models/second_level_function.dart';

/// The `ComplexityCalculator` class provides methods to calculate cognitive complexity
/// for Dart code using the AST (Abstract Syntax Tree) structure.
class CognitiveComplexityCalculator {
  /// Threshold to identify high complexity
  final int complexityThreshold;

  /// Maximum allowed nesting level
  final int maxNestingLevel;

  /// Total accumulated complexity score
  int totalComplexityScore = 0;

  /// Current nesting depth
  int currentNestingDepth = 0;

  /// Recorded complexity points
  final List<ComplexityPoint> complexityPointsList = [];

  /// Nodes with high nesting levels
  final List<String> highNestingLevelNodesList = [];

  /// Identified complexity issues
  final List<ComplexityIssue> complexityIssuesList = [];

  /// Flag for logical sequence detection
  bool isInLogicalSequence = false;

  /// Set of logical expressions considered
  Set<AstNode> consideredLogicalExpressionsSet = {};

  /// Stack of currently enclosing functions
  List<AstNode> enclosingFunctionsStack = [];

  /// List of second-level functions
  List<SecondLevelFunction> nestedFunctionsList = [];

  /// Complexity points if not nested
  List<ComplexityPoint> nonNestedComplexityPointsList = [];

  /// Complexity points if nested
  List<ComplexityPoint> nestedComplexityPointsList = [];

  /// Flag for top-level structural complexity
  bool hasTopLevelStructuralComplexity = false;

  /// Top-level own complexity points
  List<ComplexityPoint> topLevelComplexityPointsList = [];

  /// Set of nodes considered for nesting
  Set<AstNode> consideredNestingNodesSet = {};

  /// Name of the current function being analyzed
  String? currentFunctionName;

  /// Constructor to initialize the `ComplexityCalculator` with given thresholds.
  CognitiveComplexityCalculator({
    required this.complexityThreshold,
    required this.maxNestingLevel,
  });

  /// Handles entering a function node (FunctionDeclaration or FunctionExpression).
  /// - Resets the function-specific variables like nesting depth, complexity points, etc.
  /// - Stores the current function in the `enclosingFunctionsStack`.
  void enterFunctionNode(AstNode node) {
    enclosingFunctionsStack.add(node);
    nonNestedComplexityPointsList = [];
    nestedComplexityPointsList = [];
    topLevelComplexityPointsList = [];
    consideredNestingNodesSet.clear();
    currentNestingDepth = 0;
    hasTopLevelStructuralComplexity = false;
  }

  /// Handles logical expressions (&& and ||) within binary expressions.
  /// - Checks if the visitor is already inside a logical sequence.
  /// - If not, increments complexity and sets the `isInLogicalSequence` flag.
  /// - Recursively visits the left and right operands of the logical expression.
  void processLogicalExpression(
    BinaryExpression node,
    CognitiveComplexityVisitor visitor,
  ) {
    if (!isInLogicalSequence) {
      /// Check if this is a new logical sequence
      isInLogicalSequence = true;
      addFundamentalComplexity(1);

      /// Increment for the start of the sequence
    }

    /// Recursively check nested logical expressions using the visitor
    node.leftOperand.accept(visitor);
    node.rightOperand.accept(visitor);

    isInLogicalSequence = false;
  }

  /// Handles method invocations within the code.
  /// - Checks for recursive calls by comparing the invoked method name with the name of the enclosing method.
  /// - If recursion is detected, increments complexity.
  void processMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (enclosingFunctionsStack.isNotEmpty &&
        enclosingFunctionsStack.last is MethodDeclaration &&
        (enclosingFunctionsStack.last as MethodDeclaration).name.lexeme ==
            name) {
      addFundamentalComplexity(1); // Increment for recursion
    }
  }

  /// Method to increase nesting depth if the node is not already considered.
  void increaseNestingDepthIfNeeded(AstNode node) {
    if (!consideredNestingNodesSet.contains(node)) {
      currentNestingDepth++;
      consideredNestingNodesSet.add(node);
    }
  }

  /// Method to increase structural complexity and nesting depth.
  void addStructuralComplexity(int complexityPoints) {
    addComplexity(complexityPoints);
    currentNestingDepth++;
  }

  /// Method to increase hybrid complexity without changing nesting depth.
  void addHybridComplexity(int complexityPoints) {
    addComplexity(complexityPoints);
    // Do not increase nesting depth
  }

  /// Method to increase fundamental complexity without changing nesting depth.
  void addFundamentalComplexity(int complexityPoints) {
    addComplexity(complexityPoints);
    // Do not increase nesting depth
  }

  /// Increases complexity by the specified amount, considering nesting level and function context.
  /// - Creates a `ComplexityPoint` to record the added complexity and the current nesting level.
  /// - If it's a top-level structure (no enclosing function), increases the total complexity.
  /// - If it's a top-level function, marks it as having structural complexity and adds the complexity point.
  /// - Otherwise, it's a nested function, so complexity points are added to both the nested and non-nested lists.
  void addComplexity(int complexityPoints) {
    final complexityPoint = ComplexityPoint(
        complexity: complexityPoints, nestingLevel: currentNestingDepth);
    if (enclosingFunctionsStack.isEmpty) {
      // Increase total complexity for top-level structures
      totalComplexityScore += complexityPoints;
    } else if (enclosingFunctionsStack.length == 1) {
      // Increase complexity for top-level functions
      hasTopLevelStructuralComplexity = true;
      topLevelComplexityPointsList.add(complexityPoint);
    } else {
      // Increase complexity for nested functions
      nestedComplexityPointsList.add(ComplexityPoint(
        complexity: complexityPoints + 1,
        nestingLevel: currentNestingDepth,
      ));
      nonNestedComplexityPointsList.add(complexityPoint);
    }
  }

  /// Handles leaving a function node (FunctionDeclaration or FunctionExpression).
  /// - Removes the function from the `enclosingFunctionsStack`.
  /// - If it's a second-level function (nested function), adds it to the `nestedFunctionsList`.
  /// - Otherwise, checks the final complexity of the function.
  void exitFunctionNode(AstNode node) {
    enclosingFunctionsStack.removeLast();

    /// Pop the current function from the stack
    final complexityPointsList = nestedComplexityPointsList.isEmpty
        ? nonNestedComplexityPointsList
        : nestedComplexityPointsList;

    /// Check if it's a second-level function
    if (node is FunctionExpression && enclosingFunctionsStack.isNotEmpty) {
      nestedFunctionsList.add(
        SecondLevelFunction(
          node: node,
          parent: enclosingFunctionsStack.last,
          complexityIfThisSecondaryIsTopLevel: topLevelComplexityPointsList,
          complexityIfNested: complexityPointsList,
        ),
      );
    } else {
      checkFunctionComplexity(complexityPointsList, node);
    }
  }

  /// Checks the final complexity of a function after it is processed.
  /// - Calculates the total complexity of the function.
  /// - If the complexity exceeds the threshold, creates a ComplexityIssue and adds it to the `complexityIssuesList`.
  void checkFunctionComplexity(
      List<ComplexityPoint> complexityPointsList, AstNode node) {
    final complexityAmount = complexityPointsList.fold(
      0,
      (nestingLevel, point) => nestingLevel + point.complexity,
    );
    totalComplexityScore += complexityAmount;

    /// Check if complexity exceeds threshold
    if (complexityAmount > complexityThreshold) {
      /// Find the nearest ancestor that can be associated with the complexity issue
      /// (MethodDeclaration, ConstructorDeclaration, FunctionDeclaration, VariableDeclaration)
      final maybeMethod = node.thisOrAncestorOfType<MethodDeclaration>();
      final maybeConstructor =
          node.thisOrAncestorOfType<ConstructorDeclaration>();
      final maybeFunction = node.thisOrAncestorOfType<FunctionDeclaration>();
      final maybeArrowFunction =
          node.thisOrAncestorOfType<VariableDeclaration>();

      /// Add the ComplexityIssue, associating it with the relevant token
      if (maybeMethod != null) {
        complexityIssuesList.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeMethod.name,
          ),
        );
        return;
      }

      if (maybeConstructor != null) {
        complexityIssuesList.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeConstructor.name ?? maybeConstructor.beginToken,
          ),
        );
        return;
      }

      if (maybeFunction != null) {
        complexityIssuesList.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeFunction.name,
          ),
        );
        return;
      }

      if (maybeArrowFunction != null) {
        complexityIssuesList.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeArrowFunction.name,
          ),
        );
        return;
      }

      complexityIssuesList.add(
        ComplexityIssue(
          complexity: complexityAmount,
          token: node
              .beginToken, // Use the starting token of the node if no other is found
        ),
      );
    }
  }

  /// Gets sections of code with high complexity based on a nesting threshold.
  /// - Filters complexity points that exceed the `complexityThreshold` and have a nesting level higher than the `nestingThreshold`.
  /// - Returns a list of strings indicating the nesting levels where high complexity was found.
  List<String> getHighComplexitySections(int nestingThreshold) {
    return complexityPointsList
        .where((point) =>
            point.complexity > complexityThreshold &&
            point.nestingLevel > nestingThreshold)
        .map((point) => 'Nesting Level ${point.nestingLevel}')
        .toList();
  }
}
