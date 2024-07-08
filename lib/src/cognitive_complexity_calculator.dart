import 'package:analyzer/dart/ast/ast.dart';
import 'package:cognitive_complexity_analyzer/src/cognitive_complexity_visitor.dart';
import 'package:cognitive_complexity_analyzer/src/models/complexity_issue.dart';
import 'package:cognitive_complexity_analyzer/src/models/complexity_point.dart';
import 'package:cognitive_complexity_analyzer/src/models/second_level_function.dart';

/// The `ComplexityCalculator` class provides methods to calculate cognitive complexity
/// for Dart code using the AST (Abstract Syntax Tree) structure.
class ComplexityCalculator {
  /// Threshold to identify high complexity
  final int complexityThreshold;

  /// Maximum allowed nesting level
  final int maxNestingLevel;

  /// Total accumulated complexity score
  int totalComplexity = 0;

  /// Current nesting depth
  int nestingDepth = 0;

  /// Recorded complexity points
  final List<ComplexityPoint> complexityPoints = [];

  /// Nodes with high nesting levels
  final List<String> highNestingLevelNodes = [];

  /// Identified complexity issues
  final List<ComplexityIssue> issues = [];

  /// Flag for logical sequence detection
  bool isInLogicalSequence = false;

  /// Set of logical expressions considered
  Set<AstNode> consideredLogicalExpressions = {};

  /// Stack of currently enclosing functions
  List<AstNode> enclosingFunctions = [];

  /// List of second-level functions
  List<SecondLevelFunction> secondLevelFunctions = [];

  /// Complexity points if not nested
  List<ComplexityPoint> complexityIfNotNested = [];

  /// Complexity points if nested
  List<ComplexityPoint> complexityIfNested = [];

  /// Flag for top-level structural complexity
  bool topLevelHasStructuralComplexity = false;

  /// Top-level own complexity points
  List<ComplexityPoint> topLevelOwnComplexity = [];

  /// Set of nodes considered for nesting
  Set<AstNode> nestingNodes = {};

  /// Name of the current function being analyzed
  String? currentFunctionName;

  /// Constructor to initialize the `ComplexityCalculator` with given thresholds.
  ComplexityCalculator({
    required this.complexityThreshold,
    required this.maxNestingLevel,
  });

  /// Handles entering a function node (FunctionDeclaration or FunctionExpression).
  /// - Resets the function-specific variables like nesting depth, complexity points, etc.
  /// - Stores the current function in the `enclosingFunctions` stack.
  void enterFunction(AstNode node) {
    enclosingFunctions.add(node);
    complexityIfNotNested = [];
    complexityIfNested = [];
    topLevelOwnComplexity = [];
    nestingNodes.clear();
    nestingDepth = 0;
    topLevelHasStructuralComplexity = false;
  }

  /// Handles logical expressions (&& and ||) within binary expressions.
  /// - Checks if the visitor is already inside a logical sequence.
  /// - If not, increments complexity and sets the `isInLogicalSequence` flag.
  /// - Recursively visits the left and right operands of the logical expression.
  void handleLogicalExpression(
    BinaryExpression node,
    CognitiveComplexityVisitor visitor,
  ) {
    if (!isInLogicalSequence) {
      /// Check if this is a new logical sequence
      isInLogicalSequence = true;
      increaseFundamentalComplexity(
        1,
      );

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
  void handleMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (enclosingFunctions.isNotEmpty &&
        enclosingFunctions.last is MethodDeclaration &&
        (enclosingFunctions.last as MethodDeclaration).name.lexeme == name) {
      increaseFundamentalComplexity(1); // Increment for recursion
    }
  }

  /// Handles leaving a function node (FunctionDeclaration or FunctionExpression).
  /// - Removes the function from the `enclosingFunctions` stack.
  /// - If it's a second-level function (nested function), adds it to the `secondLevelFunctions` list.
  /// - Otherwise, checks the final complexity of the function.
  void leaveFunction(AstNode node) {
    enclosingFunctions.removeLast();

    /// Pop the current function from the stack
    final complexity =
        complexityIfNested.isEmpty ? complexityIfNotNested : complexityIfNested;

    /// Check if it's a second-level function
    if (node is FunctionExpression && enclosingFunctions.isNotEmpty) {
      secondLevelFunctions.add(
        SecondLevelFunction(
          node: node,
          parent: enclosingFunctions.last,
          complexityIfThisSecondaryIsTopLevel: topLevelOwnComplexity,
          complexityIfNested: complexity,
        ),
      );
    } else {
      checkFunction(complexity, node);
    }
  }

  /// Checks the final complexity of a function after it is processed.
  /// - Calculates the total complexity of the function.
  /// - If the complexity exceeds the threshold, creates a ComplexityIssue and adds it to the `issues` list.
  void checkFunction(List<ComplexityPoint> complexity, AstNode node) {
    final complexityAmount = complexity.fold(
      0,
      (nestingLevel, point) => nestingLevel + point.complexity,
    );
    totalComplexity += complexityAmount;

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
        issues.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeMethod.name,
          ),
        );
        return;
      }

      if (maybeConstructor != null) {
        issues.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeConstructor.name ?? maybeConstructor.beginToken,
          ),
        );
        return;
      }

      if (maybeFunction != null) {
        issues.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeFunction.name,
          ),
        );
        return;
      }

      if (maybeArrowFunction != null) {
        issues.add(
          ComplexityIssue(
            complexity: complexityAmount,
            token: maybeArrowFunction.name,
          ),
        );
        return;
      }

      issues.add(
        ComplexityIssue(
          complexity: complexityAmount,
          token: node
              .beginToken, // Use the starting token of the node if no other is found
        ),
      );
    }
  }

  /// Method to increase structural complexity and nesting depth.
  void increaseStructuralComplexity(int added) {
    increaseComplexity(added);
    nestingDepth++;
  }

  /// Method to increase hybrid complexity without changing nesting depth.
  void increaseHybridComplexity(int added) {
    increaseComplexity(added);
    // Do not increase nesting depth
  }

  /// Method to increase fundamental complexity without changing nesting depth.
  void increaseFundamentalComplexity(int added) {
    increaseComplexity(added);
    // Do not increase nesting depth
  }

  /// Method to increase nesting depth if the node is not already considered.
  void increaseNestingIfNeeded(AstNode node) {
    if (!nestingNodes.contains(node)) {
      nestingDepth++;
      nestingNodes.add(node);
    }
  }

  /// Increases complexity by the specified amount, considering nesting level and function context.
  /// - Creates a `ComplexityPoint` to record the added complexity and the current nesting level.
  /// - If it's a top-level structure (no enclosing function), increases the total complexity.
  /// - If it's a top-level function, marks it as having structural complexity and adds the complexity point.
  /// - Otherwise, it's a nested function, so complexity points are added to both the nested and non-nested lists.
  void increaseComplexity(int added) {
    final complexityPoint =
        ComplexityPoint(complexity: added, nestingLevel: nestingDepth);
    if (enclosingFunctions.isEmpty) {
      // Increase total complexity for top-level structures
      totalComplexity += added;
    } else if (enclosingFunctions.length == 1) {
      // Increase complexity for top-level functions
      topLevelHasStructuralComplexity = true;
      topLevelOwnComplexity.add(complexityPoint);
    } else {
      // Increase complexity for nested functions
      complexityIfNested.add(ComplexityPoint(
        complexity: added + 1,
        nestingLevel: nestingDepth,
      ));
      complexityIfNotNested.add(complexityPoint);
    }
  }

  /// Gets sections of code with high complexity based on a nesting threshold.
  /// - Filters complexity points that exceed the `complexityThreshold` and have a nesting level higher than the `nestingThreshold`.
  /// - Returns a list of strings indicating the nesting levels where high complexity was found.
  List<String> getHighComplexitySections(int nestingThreshold) {
    return complexityPoints
        .where((point) =>
            point.complexity > complexityThreshold &&
            point.nestingLevel > nestingThreshold)
        .map((point) => 'Nesting Level ${point.nestingLevel}')
        .toList();
  }
}
