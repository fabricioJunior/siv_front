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
    String? logradouro,
    String? numero,
    String? bairro,
    String? codigoMunicipioIbge,
    String? municipio,
    String? cep,
  }) async {
    var novaEmpresa = Empresa.create(
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
      logradouro: logradouro,
      numero: numero,
      bairro: bairro,
      codigoMunicipioIbge: codigoMunicipioIbge,
      municipio: municipio,
      cep: cep,
    );
    return _empresasRepository.criarNovaEmpresa(
      novaEmpresa,
    );
  }
}
