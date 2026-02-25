/// Types of calculator buttons for styling and feedback
enum ButtonType {
  number,
  operation,
  function,
  equals,
  clear,
  memory,
}

extension ButtonTypeExtension on ButtonType {
  /// Whether this button should use accent color
  bool get isAccent {
    switch (this) {
      case ButtonType.operation:
      case ButtonType.equals:
        return true;
      default:
        return false;
    }
  }

  /// Whether this button should be larger
  bool get isProminent {
    return this == ButtonType.equals;
  }
}
