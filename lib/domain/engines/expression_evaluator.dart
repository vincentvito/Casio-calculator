import 'dart:math' as math;

/// Token types for the expression parser
enum TokenType {
  number,
  operator,
  function,
  leftParen,
  rightParen,
  constant,
}

/// Represents a token in the expression
class Token {
  final TokenType type;
  final String value;
  final double? numValue;

  Token(this.type, this.value, [this.numValue]);

  @override
  String toString() => 'Token($type, $value)';
}

/// Expression evaluator using the Shunting-yard algorithm
/// Supports: +, -, *, /, ^, parentheses, and scientific functions
class ExpressionEvaluator {
  // Operator precedence (higher = evaluated first)
  static const Map<String, int> _precedence = {
    '+': 1,
    '-': 1,
    '×': 2,
    '*': 2,
    '÷': 2,
    '/': 2,
    '^': 3,
  };

  // Right-associative operators
  static const Set<String> _rightAssociative = {'^'};

  // Supported functions
  static const Set<String> _functions = {
    'sin', 'cos', 'tan',
    'asin', 'acos', 'atan',
    'ln', 'log',
    'sqrt', 'cbrt',
    'abs', 'exp',
    'sinh', 'cosh', 'tanh',
  };

  // Constants
  static const Map<String, double> _constants = {
    'π': math.pi,
    'pi': math.pi,
    'e': math.e,
  };

  bool isRadianMode;

  ExpressionEvaluator({this.isRadianMode = false});

  /// Evaluate an expression string and return the result
  double evaluate(String expression) {
    final tokens = _tokenize(expression);
    final rpn = _shuntingYard(tokens);
    return _evaluateRPN(rpn);
  }

  /// Tokenize the expression string
  List<Token> _tokenize(String expression) {
    final tokens = <Token>[];
    final normalized = expression
        .replaceAll(' ', '')
        .replaceAll('−', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    int i = 0;
    while (i < normalized.length) {
      final char = normalized[i];

      // Check for numbers (including negative numbers at start or after operator/paren)
      if (_isDigit(char) || char == '.' ||
          (char == '-' && (tokens.isEmpty ||
              tokens.last.type == TokenType.operator ||
              tokens.last.type == TokenType.leftParen ||
              tokens.last.type == TokenType.function))) {
        final numStart = i;
        if (char == '-') i++;

        while (i < normalized.length &&
            (_isDigit(normalized[i]) || normalized[i] == '.')) {
          i++;
        }

        // Check for scientific notation
        if (i < normalized.length &&
            (normalized[i] == 'e' || normalized[i] == 'E')) {
          i++;
          if (i < normalized.length &&
              (normalized[i] == '+' || normalized[i] == '-')) {
            i++;
          }
          while (i < normalized.length && _isDigit(normalized[i])) {
            i++;
          }
        }

        final numStr = normalized.substring(numStart, i);
        final numValue = double.parse(numStr);
        tokens.add(Token(TokenType.number, numStr, numValue));
        continue;
      }

      // Check for operators
      if (_precedence.containsKey(char)) {
        tokens.add(Token(TokenType.operator, char));
        i++;
        continue;
      }

      // Check for parentheses
      if (char == '(') {
        tokens.add(Token(TokenType.leftParen, char));
        i++;
        continue;
      }
      if (char == ')') {
        tokens.add(Token(TokenType.rightParen, char));
        i++;
        continue;
      }

      // Check for functions and constants
      if (_isLetter(char)) {
        final wordStart = i;
        while (i < normalized.length && _isLetter(normalized[i])) {
          i++;
        }
        final word = normalized.substring(wordStart, i);

        if (_constants.containsKey(word)) {
          tokens.add(Token(TokenType.constant, word, _constants[word]));
        } else if (_functions.contains(word)) {
          tokens.add(Token(TokenType.function, word));
        } else {
          throw FormatException('Unknown identifier: $word');
        }
        continue;
      }

      // Check for π symbol
      if (char == 'π') {
        tokens.add(Token(TokenType.constant, 'π', math.pi));
        i++;
        continue;
      }

      // Skip unknown characters (shouldn't happen with valid input)
      i++;
    }

    return tokens;
  }

  /// Convert infix tokens to Reverse Polish Notation using Shunting-yard
  List<Token> _shuntingYard(List<Token> tokens) {
    final output = <Token>[];
    final operatorStack = <Token>[];

    for (final token in tokens) {
      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          output.add(token);

        case TokenType.function:
          operatorStack.add(token);

        case TokenType.operator:
          while (operatorStack.isNotEmpty) {
            final top = operatorStack.last;
            if (top.type == TokenType.leftParen) break;
            if (top.type == TokenType.function) {
              output.add(operatorStack.removeLast());
              continue;
            }

            final topPrec = _precedence[top.value] ?? 0;
            final tokenPrec = _precedence[token.value] ?? 0;

            if (topPrec > tokenPrec ||
                (topPrec == tokenPrec &&
                    !_rightAssociative.contains(token.value))) {
              output.add(operatorStack.removeLast());
            } else {
              break;
            }
          }
          operatorStack.add(token);

        case TokenType.leftParen:
          operatorStack.add(token);

        case TokenType.rightParen:
          while (operatorStack.isNotEmpty &&
              operatorStack.last.type != TokenType.leftParen) {
            output.add(operatorStack.removeLast());
          }
          if (operatorStack.isEmpty) {
            throw FormatException('Mismatched parentheses');
          }
          operatorStack.removeLast(); // Remove the left paren

          // If there's a function before the paren, add it to output
          if (operatorStack.isNotEmpty &&
              operatorStack.last.type == TokenType.function) {
            output.add(operatorStack.removeLast());
          }
      }
    }

    // Pop remaining operators
    while (operatorStack.isNotEmpty) {
      final op = operatorStack.removeLast();
      if (op.type == TokenType.leftParen) {
        throw FormatException('Mismatched parentheses');
      }
      output.add(op);
    }

    return output;
  }

  /// Evaluate Reverse Polish Notation
  double _evaluateRPN(List<Token> rpn) {
    final stack = <double>[];

    for (final token in rpn) {
      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          stack.add(token.numValue!);

        case TokenType.operator:
          if (stack.length < 2) {
            throw FormatException('Invalid expression');
          }
          final b = stack.removeLast();
          final a = stack.removeLast();
          stack.add(_applyOperator(token.value, a, b));

        case TokenType.function:
          if (stack.isEmpty) {
            throw FormatException('Invalid expression');
          }
          final arg = stack.removeLast();
          stack.add(_applyFunction(token.value, arg));

        default:
          throw FormatException('Unexpected token: $token');
      }
    }

    if (stack.length != 1) {
      throw FormatException('Invalid expression');
    }

    return stack.first;
  }

  double _applyOperator(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
      case '×':
        return a * b;
      case '/':
      case '÷':
        if (b == 0) throw FormatException('Division by zero');
        return a / b;
      case '^':
        return math.pow(a, b).toDouble();
      default:
        throw FormatException('Unknown operator: $op');
    }
  }

  double _applyFunction(String func, double arg) {
    // Convert to radians if in degree mode for trig functions
    double toRadians(double deg) => isRadianMode ? deg : deg * math.pi / 180;
    double fromRadians(double rad) => isRadianMode ? rad : rad * 180 / math.pi;

    switch (func) {
      case 'sin':
        return math.sin(toRadians(arg));
      case 'cos':
        return math.cos(toRadians(arg));
      case 'tan':
        return math.tan(toRadians(arg));
      case 'asin':
        if (arg < -1 || arg > 1) throw FormatException('Domain error');
        return fromRadians(math.asin(arg));
      case 'acos':
        if (arg < -1 || arg > 1) throw FormatException('Domain error');
        return fromRadians(math.acos(arg));
      case 'atan':
        return fromRadians(math.atan(arg));
      case 'ln':
        if (arg <= 0) throw FormatException('Domain error');
        return math.log(arg);
      case 'log':
        if (arg <= 0) throw FormatException('Domain error');
        return math.log(arg) / math.ln10;
      case 'sqrt':
        if (arg < 0) throw FormatException('Domain error');
        return math.sqrt(arg);
      case 'cbrt':
        return arg < 0 ? -math.pow(-arg, 1 / 3).toDouble() : math.pow(arg, 1 / 3).toDouble();
      case 'abs':
        return arg.abs();
      case 'exp':
        return math.exp(arg);
      case 'sinh':
        return (math.exp(arg) - math.exp(-arg)) / 2;
      case 'cosh':
        return (math.exp(arg) + math.exp(-arg)) / 2;
      case 'tanh':
        final e2x = math.exp(2 * arg);
        return (e2x - 1) / (e2x + 1);
      default:
        throw FormatException('Unknown function: $func');
    }
  }

  bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
