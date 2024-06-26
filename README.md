## Intro

Cognitive complexity allows us to measure the complexity of a piece of code with more accuracy. While it provides a decent overall assessment, it does overlook some important aspects that make code harder to understand.

## Features
- Leverages Analyzer Packages: Utilizes the src.analyzer package to navigate the Abstract Syntax Tree (AST) of your Dart code.
- Tracks Nesting Levels: Keeps track of the current nesting level (e.g., if statements within if statements) to account for increased complexity.
- Considers Different Constructs: Assigns different base complexity values for various control flow statements (if, for, while, etc.) and expressions (logical operators, conditional expressions).
- Handles Recursion: It identifies and adds complexity for recursive method calls.
- Provides Complexity Score and High-Complexity Sections: Calculates a total complexity score and identifies lines exceeding a certain complexity threshold within a specific nesting depth.

## How it calculates

the calculation is based on many factors and uses a points system based on each factor to evaluate if there is a cognitive issue or not

- +1 point: for conditional statements (if, else if, switch)
- +1 points: for nested conditional statements (if inside an if)
- +2 point: for loops (for, while)
- +1 point: for complex expressions (functions within expressions)
- +2 points: for recursive functions

## Getting started

TODO: This package depends on src.analyzer package

## Usage

1- Add package to your pubspec.yaml file like this : 

```
  cognitive_complexity_analyzer:
    git:
      url: https://github.com/MomenMuhammad01/cognitive_complexity_analyzer.git
```
2- Run The code in your project commandline with the following commands 

- Without Custom Settings 
```Command
dart run --enable-vm-service cognitive_complexity_analyzer [REPLACE WITH FOLDER NAME THAT YOU WANT TO ANALYZE]
```

- With Custom Settings
```Command
dart run --enable-vm-service cognitive_complexity_analyzer [REPLACE WITH FOLDER NAME THAT YOU WANT TO ANALYZE] [COMPLEXITY NUM] [HighNestingThreshold]
```
- Examples : 


```
dart run --enable-vm-service cognitive_complexity_analyzer /path/to/your/project/src  # Without Custom Settings
```

```
dart run --enable-vm-service cognitive_complexity_analyzer /path/to/your/project/src 20 4  #  maxComplexity 20 and highNestingThreshold 4
```

## Generated Report File

- The package will generate a report file containes all the informations about the files that has a cognitive complexity issues.
- Each file represented with a path and a cognitive score
- The Generated report contains the date and time of generation EXAMPLE : cognitive_complexity_report-2024-06-26-16:43.txt

