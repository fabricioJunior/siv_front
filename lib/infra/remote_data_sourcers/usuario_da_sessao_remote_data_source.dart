import 'package:autenticacao/domain/models/usuario.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:autenticacao/data.dart';
import 'package:siv_front/infra/remote_data_sourcers/dtos/usuario_dto.dart';

class UsuarioDaSessaoRemoteDataSource extends RemoteDataSourceBase
    implements IUsuarioDaSessaoRemoteDataSource {
  UsuarioDaSessaoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/perfil';

  @override
  Future<Usuario> getUsuario() async {
    var response = await get();

    return UsuarioDto.fromJson(response.body);
  }
}
