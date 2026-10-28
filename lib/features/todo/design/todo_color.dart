import 'package:flutter/material.dart';
import 'package:flutter_starter_app/shared/design_system/design_system.dart';

final class TodoColor extends ColorData {
  const TodoColor({required this.pending, required this.completed});

  final Color pending;
  final Color completed;

  static const light = TodoColor(
    pending: Color(0xFF2563EB),
    completed: Color(0xFF16A34A),
  );

  static const dark = TodoColor(
    pending: Color(0xFF60A5FA),
    completed: Color(0xFF4ADE80),
  );

  @override
  TodoColor lerp(ColorData? other, double t) {
    if (other is! TodoColor) return this;
    return TodoColor(
      pending: Color.lerp(pending, other.pending, t)!,
      completed: Color.lerp(completed, other.completed, t)!,
    );
  }
}
