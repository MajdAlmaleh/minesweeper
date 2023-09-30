import 'package:flutter_riverpod/flutter_riverpod.dart';

class EndNotifier extends StateNotifier<int> {
  EndNotifier() : super(0);

  void end() {
    state++;
    print(state);
  }

  void end1() {
    state--;
    print(state);
  }

  void reset() {
    state = 0;
  }

  void change(int x) {
    state = x;
  }

  int getPressed() {
    return state;
  }
}

final getEndedProvider =
    StateNotifierProvider<EndNotifier, int>((ref) => EndNotifier());
