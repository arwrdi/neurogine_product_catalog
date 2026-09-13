import 'dart:async';

class Debounce {
  Debounce({this.delay = const Duration(milliseconds: 450)});

  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => cancel();
}
