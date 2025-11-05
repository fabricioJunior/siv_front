    import 'dart:async';
    import 'package:flutter/foundation.dart'; // For @required

    class Debouncer {
      final int milliseconds;
      VoidCallback? action;
      Timer? _timer;

      Debouncer({required this.milliseconds});

      run(VoidCallback action) {
        if (_timer != null) {
          _timer!.cancel();
        }
        _timer = Timer(Duration(milliseconds: milliseconds), action);
      }

      cancel() {
        if (_timer != null) {
          _timer!.cancel();
        }
      }
    }