/// Scientific calculator functions
enum ScientificFunction {
  // Trigonometric
  sin,
  cos,
  tan,
  asin,
  acos,
  atan,

  // Hyperbolic
  sinh,
  cosh,
  tanh,
  asinh,
  acosh,
  atanh,

  // Logarithmic
  ln,
  log,
  log2,

  // Powers and roots
  square,
  cube,
  power,
  sqrt,
  cbrt,
  nthRoot,

  // Other
  factorial,
  reciprocal,
  absolute,
  exp,
}

extension ScientificFunctionExtension on ScientificFunction {
  String get symbol {
    switch (this) {
      case ScientificFunction.sin:
        return 'sin';
      case ScientificFunction.cos:
        return 'cos';
      case ScientificFunction.tan:
        return 'tan';
      case ScientificFunction.asin:
        return 'sin⁻¹';
      case ScientificFunction.acos:
        return 'cos⁻¹';
      case ScientificFunction.atan:
        return 'tan⁻¹';
      case ScientificFunction.sinh:
        return 'sinh';
      case ScientificFunction.cosh:
        return 'cosh';
      case ScientificFunction.tanh:
        return 'tanh';
      case ScientificFunction.asinh:
        return 'sinh⁻¹';
      case ScientificFunction.acosh:
        return 'cosh⁻¹';
      case ScientificFunction.atanh:
        return 'tanh⁻¹';
      case ScientificFunction.ln:
        return 'ln';
      case ScientificFunction.log:
        return 'log';
      case ScientificFunction.log2:
        return 'log₂';
      case ScientificFunction.square:
        return 'x²';
      case ScientificFunction.cube:
        return 'x³';
      case ScientificFunction.power:
        return 'xʸ';
      case ScientificFunction.sqrt:
        return '√';
      case ScientificFunction.cbrt:
        return '³√';
      case ScientificFunction.nthRoot:
        return 'ⁿ√';
      case ScientificFunction.factorial:
        return 'n!';
      case ScientificFunction.reciprocal:
        return '1/x';
      case ScientificFunction.absolute:
        return '|x|';
      case ScientificFunction.exp:
        return 'eˣ';
    }
  }

  bool get isUnary {
    switch (this) {
      case ScientificFunction.power:
      case ScientificFunction.nthRoot:
        return false;
      default:
        return true;
    }
  }
}
