part of 'empresa_bloc.dart';

abstract class EmpresaEvent {}

class EmpresaIniciou extends EmpresaEvent {
  final int? idEmpresa;

  EmpresaIniciou({required this.idEmpresa});
}

class EmpresaEditou extends EmpresaEvent {
  final String? cnpj;
  final String? codigoDeAtividade;
  final String? codigoDeNaturezaJuridica;
  final String? email;
  final String? inscricaoEstadual;
  final String? nome;
  final String? nomeFantasia;
  final TipoRegimeEmpresa? regime;
  final String? registroMunicipal;
  final TipoDeSubstituicaoTributaria? substituicaoTributaria;
  final String? telefone;
  final String? uf;
  final int? id;
  final String? logradouro;
  final String? numero;
  final String? bairro;
  final String? codigoMunicipioIbge;
  final String? municipio;
  final String? cep;
  final double? latitude;
  final double? longitude;

  EmpresaEditou({
    this.id,
    this.cnpj,
    this.codigoDeAtividade,
    this.codigoDeNaturezaJuridica,
    this.email,
    this.inscricaoEstadual,
    this.nome,
    this.nomeFantasia,
    this.regime,
    this.registroMunicipal,
    this.substituicaoTributaria,
    this.telefone,
    this.uf,
    this.logradouro,
    this.numero,
    this.bairro,
    this.codigoMunicipioIbge,
    this.municipio,
    this.cep,
    this.latitude,
    this.longitude,
  });
}

class EmpresaSalvou extends EmpresaEvent {}
