/// 将任意值转换为 JSON 友好的类型（递归处理 Map / List）。
dynamic encodeJsonFriendly(dynamic value) {
  if (value == null) return null;
  if (value is String || value is num || value is bool) return value;
  if (value is Map) {
    return value.map(
      (k, v) => MapEntry(k.toString(), encodeJsonFriendly(v)),
    );
  }
  if (value is Iterable) {
    return value.map(encodeJsonFriendly).toList();
  }
  return value.toString();
}
