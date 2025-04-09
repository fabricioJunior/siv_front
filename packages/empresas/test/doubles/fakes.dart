import 'package:empresas/domain/entities/empresa.dart';

Empresa fakeEmpresa({
  String cnpj = 'cnpj',
  String codigoDeAtividade = 'codigoDeAtividade',
  String codigoDeNaturezaJuridica = 'codigoDeNaturezaJuridica',
  String email = 'email',
  int id = 123,
  String inscricaoEstadual = 'inscricao estadual',
  String nome = 'nome',
  String nomeFantasia = 'nomeFantasia',
  TipoRegimeEmpresa regime = TipoRegimeEmpresa.normal,
  String registroMunicipal = 'registro municipal',
  TipoDeSubstituicaoTributaria substituicaoTributaria =
      TipoDeSubstituicaoTributaria.naoCalcula,
  String telefone = 'telefone',
  String uf = 'uf',
}) =>
    Empresa.instance(
      cnpj: cnpj,
      codigoDeAtividade: codigoDeAtividade,
      codigoDeNaturezaJuridica: codigoDeNaturezaJuridica,
      email: email,
      id: id,
      inscricaoEstadual: inscricaoEstadual,
      nome: nome,
      nomeFantasia: nomeFantasia,
      regime: regime,
      registroMunicipal: registroMunicipal,
      substituicaoTributaria: substituicaoTributaria,
      telefone: telefone,
      uf: uf,
    );
