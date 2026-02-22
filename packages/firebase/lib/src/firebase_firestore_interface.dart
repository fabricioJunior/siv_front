class FirebaseDocumento {
  final String id;
  final Map<String, dynamic> dados;

  const FirebaseDocumento({
    required this.id,
    required this.dados,
  });
}

abstract class IFirebaseFirestore {
  Future<List<FirebaseDocumento>> recuperarDocumentos(String colecao);
}
