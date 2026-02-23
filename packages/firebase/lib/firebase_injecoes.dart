import 'package:core/injecoes.dart';

import 'firebase.dart';

Future<void> resolverDependenciasFirebase() async {
  sl.registerLazySingleton<IFirebaseCore>(
    () => FirebaseCoreGateway(),
  );
  await sl<IFirebaseCore>().initialize();
  sl.registerLazySingleton<IFirebaseFirestore>(
    () => FirebaseFirestoreGateway(),
  );
}
