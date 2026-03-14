import 'package:uuid/uuid.dart';

class CriarIdempotencyKey {
  String call() {
    return const Uuid().v4();
  }
}
