/// List extensions for common operations
extension ListExtension<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;

  /// Separate list with a value
  List<T> separatedBy(T separator) {
    if (isEmpty) return [];
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}
