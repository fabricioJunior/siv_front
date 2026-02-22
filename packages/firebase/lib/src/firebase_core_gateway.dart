import 'package:firebase/src/firebase_options.dart';

import 'firebase_core_interface.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseCoreGateway implements IFirebaseCore {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
