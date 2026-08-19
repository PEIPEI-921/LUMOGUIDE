extension StringOptionalExt on String? {
  bool get isEmpty => this == null || this!.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

extension ListOptionalExt<T> on List<T>? {
  bool get isEmpty => this == null || this!.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

extension MapOptionalExt<K, V> on Map<K, V>? {
  bool get isEmpty => this == null || this!.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
