import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLocalizationDelegatesProvider =
    Provider<List<LocalizationsDelegate<dynamic>>>((ref) => const []);
