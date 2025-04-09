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
  });
}

class EmpresaSalvou extends EmpresaEvent {}
