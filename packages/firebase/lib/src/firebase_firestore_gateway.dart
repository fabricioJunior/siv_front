import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_firestore_interface.dart';

class FirebaseFirestoreGateway implements IFirebaseFirestore {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreGateway({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
