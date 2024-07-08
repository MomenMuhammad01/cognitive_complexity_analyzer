## Intro

Cognitive complexity allows us to measure the complexity of a piece of code with more accuracy. While it provides a decent overall assessment, it does overlook some important aspects that make code harder to understand.

## Features
- Leverages Analyzer Packages: Utilizes the src.analyzer package to navigate the Abstract Syntax Tree (AST) of your Dart code.
- Tracks Nesting Levels: Keeps track of the current nesting level (e.g., if statements within if statements) to account for increased complexity.
- Considers Different Constructs: Assigns different base complexity values for various control flow statements (if, for, while, etc.) and expressions (logical operators, conditional expressions).
- Handles Recursion: It identifies and adds complexity for recursive method calls.
- Provides Complexity Score and High-Complexity Sections: Calculates a total complexity score and identifies lines exceeding a certain complexity threshold within a specific nesting depth.

## How it calculates

The analysis relies heavily on traversing the Dart code's AST. This allows you to examine the structural elements of the code (functions, statements, expressions) and their relationships.
Complexity Factors Considered:

## Control Flow Structures:

## Structural Complexity:
- Each control flow structure (e.g., if, else, for, while, do, switch, catch, try) increases complexity by 1.
- Nesting: Further nested control structures contribute to the complexity score.
- The nesting depth is tracked, and exceeding the maxNestingLevel threshold is flagged as an issue.
  
## Hybrid Complexity:
- This is a special case for else statements, which contribute to complexity but are not considered nested.

## Logical Operators: Logical AND (&&) and OR (||)
- operators within binary expressions are treated as additional control flow paths, contributing to complexity.

## Functions:
- Recursion: If a method calls itself (direct recursion), it increases complexity.
- Second-Level Functions (Nested Functions): The code specifically tracks nested functions and their complexities to assess their impact on the overall score.
Other Factors:

## Labeled Breaks and Continues:
-- These are considered more complex than unlabeled ones due to the introduced jump in control flow.
-- Early Returns: These are ignored



## Getting started

TODO: This package depends on src.analyzer package

## Usage

1- Add package to your pubspec.yaml file like this : 

```
  cognitive_complexity_analyzer:
    git:
      url: https://github.com/MomenMuhammad01/cognitive_complexity_analyzer.git
```
2- Run The code in your project commandline with the following commands flags

- All Commands Flags

```
-d, --directory                 The directory containing Dart files to analyze. [REQUIRED]
-m, --max-complexity            Maximum cognitive complexity score a file shouldn't pass. 
                                (defaults to "15") [NOT REQUIRED]
-n, --high-nesting-threshold    Maximum nesting level allowed for a function.
                                (defaults to "3") [NOT REQUIRED]
-s, --show-paths-as-tree        Maximum nesting level allowed for a function.
                                (defaults to "false") [NOT REQUIRED]
-e, --exclude                   Use it to exclude files pattern from analyzer example : [_generated.dart,] [NOT REQUIRED]
-h, --help                      Show usage information. 
```
- Command Example
```
dart run  cognitive_complexity_analyzer --dictionery [REPLACE WITH FOLDER NAME THAT YOU WANT TO ANALYZE]
```




## Generated Report File

- The package will generate a report file containes all the informations about the files that has a cognitive complexity issues.
- Each file represented with a path and a cognitive score
- The Generated report contains the date and time of generation EXAMPLE : cognitive_complexity_report-2024-06-26-16:43.txt

