import 'package:autenticacao/domain/data/data_sourcers/remote/i_licenciados_remote_data_source.dart';
import 'package:autenticacao/domain/models/licenciado.dart';
import 'package:firebase/firebase.dart';

class LicenciadosRemoteDataSource implements ILicenciadosRemoteDataSource {
  final IFirebaseFirestore firestore;

  LicenciadosRemoteDataSource({required this.firestore});

  @override
  Future<List<Licenciado>> recuperarLicenciados() async {
    var documentos = await firestore.recuperarDocumentos('licenciados');

    return documentos.map((doc) {
      var json = doc.dados;
      var nome = (json['nome'] ?? '').toString();
      var urlApi = (json['urlApi'] ?? json['url_api'] ?? '').toString();

      return Licenciado(
        id: doc.id,
        nome: nome,
        urlApi: urlApi,
      );
    }).where((licenciado) {
      return licenciado.nome.isNotEmpty && licenciado.urlApi.isNotEmpty;
    }).toList();
  }
}
