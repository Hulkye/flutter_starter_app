/// 判断 location 是否为应用内根路径。
bool isInternalLocation(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.hasScheme == false &&
      uri.hasAuthority == false &&
      uri.path.startsWith('/');
}

/// 校验并返回应用内根路径 location。
String requireInternalLocation(String value) {
  if (!isInternalLocation(value)) {
    throw StateError('Route location must be an internal root path: $value');
  }
  return value;
}
