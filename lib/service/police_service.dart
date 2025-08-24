import 'package:flutter_riverpod/flutter_riverpod.dart';

class PoliceService {
  static final policy = StateProvider.autoDispose((ref) => false);
  static final terms = StateProvider.autoDispose((ref) => false);
}
