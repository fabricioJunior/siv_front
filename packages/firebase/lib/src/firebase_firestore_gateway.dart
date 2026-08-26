import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_firestore_interface.dart';

class FirebaseFirestoreGateway implements IFirebaseFirestore {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreGateway({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    // No web, o WebChannel (transporte padrão) trava sem erro em ambientes
    // que bloqueiam streaming (proxy corporativo, browser automatizado/
    // headless, algumas VPNs) -- o SDK do Firestore recomenda detectar e
    // cair pra long-polling automaticamente nesses casos.
    if (kIsWeb) {
      _firestore.settings = const Settings(
        webExperimentalAutoDetectLongPolling: true,
      );
    }
  }

  @override
  Future<List<FirebaseDocumento>> recuperarDocumentos(String colecao) async {
    var snapshot = await _firestore.collection(colecao).get();

    return snapshot.docs
        .map(
          (doc) => FirebaseDocumento(
            id: doc.id,
            dados: doc.data(),
          ),
        )
        .toList();
  }
}
