import '../../data/repositories/i_empresas_repository.dart';
import '../../data/repositories/i_grupos_de_acesso_repository.dart';
import '../../models/vinculo_grupo_de_acesso_e_usuario.dart';

class RecuperarVinculosGrupoDeAcessoDoUsuario {
  final IGruposDeAcessoRepository _repository;
  final IEmpresasRepository _empresasRepository;

  RecuperarVinculosGrupoDeAcessoDoUsuario({
    required IGruposDeAcessoRepository repository,
    required IEmpresasRepository empresasRepository,
  })  : _repository = repository,
        _empresasRepository = empresasRepository;

  Future<List<VinculoGrupoDeAcessoEUsuario>> call({
    required int idUsuario,
  }) async {
    var empresas = await _empresasRepository.getEmpresas();
    var vinculos =
        await _repository.grupoDeAcessoDoUsuarioEIdEmpresa(idUsuario);
    return vinculos.map((vinculo) {
      var empresa = empresas.firstWhere((e) => e.id == vinculo.idEmpresa);
      return vinculo.copyWith(empresa: empresa);
    }).toList();
  }
}
