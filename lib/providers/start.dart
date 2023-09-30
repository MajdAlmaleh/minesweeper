import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartNotifier extends StateNotifier<bool> {
  StartNotifier() : super(false);

  void start() {
    state = true;
  }

  void reset() {
    state = false;
  }

  bool getState() {
    return state;
  }
}

final getStartedProvider =
    StateNotifierProvider<StartNotifier, bool>((ref) => StartNotifier());
