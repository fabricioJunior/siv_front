import 'package:core/injecoes.dart';

import 'firebase.dart';

void resolverDependenciasFirebase() {
  sl.registerLazySingleton<IFirebaseCore>(
    () => FirebaseCoreGateway(),
  );

  sl.registerLazySingleton<IFirebaseFirestore>(
    () => FirebaseFirestoreGateway(),
  );
}
