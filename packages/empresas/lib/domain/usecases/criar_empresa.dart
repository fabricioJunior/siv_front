import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';

import '../entities/empresa.dart';

class CriarEmpresa {
  final IEmpresasRepository _empresasRepository;

  CriarEmpresa(
    this._empresasRepository,
  );

  Future<Empresa> call({
    required String cnpj,
    required String? codigoDeAtividade,
    required String? codigoDeNaturezaJuridica,
    required String email,
    required String? inscricaoEstadual,
    required String nome,
    required String nomeFantasia,
    required TipoRegimeEmpresa? regime,
    required String? registroMunicipal,
    required TipoDeSubstituicaoTributaria? substituicaoTributaria,
    required String? telefone,
    required String? uf,
  }) async {
    var novaEmpresa = Empresa.instance(
      cnpj: cnpj,
      codigoDeAtividade: codigoDeAtividade,
      codigoDeNaturezaJuridica: codigoDeNaturezaJuridica,
      email: email,
      id: null,
      inscricaoEstadual: inscricaoEstadual,
      nome: nome,
      nomeFantasia: nomeFantasia,
      regime: regime,
      registroMunicipal: registroMunicipal,
      substituicaoTributaria: substituicaoTributaria,
      telefone: telefone,
      uf: uf,
    );
    return _empresasRepository.criarNovaEmpresa(
      novaEmpresa,
    );
  }
}
