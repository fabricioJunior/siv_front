// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'empresa_bloc.dart';

abstract class EmpresaState extends Equatable {
  Empresa? get empresa => null;
  @override
  List<Object?> get props => [];
}

class EmpresaNaoInicializada extends EmpresaState {}

class EmpresaCarregarEmProgresso extends EmpresaState {}

class EmpresaCarregarSucesso extends EmpresaState {
  @override
  final Empresa empresa;

  EmpresaCarregarSucesso({required this.empresa});
}

class EmpresaCarregarFalha extends EmpresaState {}

class EmpresaEditarEmProgresso extends EmpresaState {
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

  @override
  final Empresa? empresa;

  EmpresaEditarEmProgresso({
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
    this.id,
    this.empresa,
  });

  EmpresaEditarEmProgresso.fromEmpresa(Empresa? this.empresa)
      : cnpj = empresa?.cnpj,
        codigoDeAtividade = empresa?.codigoDeAtividade,
        codigoDeNaturezaJuridica = empresa?.codigoDeNaturezaJuridica,
        email = empresa?.email,
        inscricaoEstadual = empresa?.inscricaoEstadual,
        nome = empresa?.nome,
        nomeFantasia = empresa?.nomeFantasia,
        regime = empresa?.regime,
        registroMunicipal = empresa?.registroMunicipal,
        telefone = empresa?.telefone,
        uf = empresa?.uf,
        substituicaoTributaria = empresa?.substituicaoTributaria,
        id = empresa?.id;

  @override
  List<Object?> get props => [
        cnpj,
        codigoDeAtividade,
        codigoDeNaturezaJuridica,
        email,
        inscricaoEstadual,
        nome,
        nomeFantasia,
        regime,
        registroMunicipal,
        substituicaoTributaria,
        telefone,
        uf,
      ];

  EmpresaEditarEmProgresso copyWith({
    String? cnpj,
    String? codigoDeAtividade,
    String? codigoDeNaturezaJuridica,
    String? email,
    String? inscricaoEstadual,
    String? nome,
    String? nomeFantasia,
    TipoRegimeEmpresa? regime,
    String? registroMunicipal,
    TipoDeSubstituicaoTributaria? substituicaoTributaria,
    String? telefone,
    String? uf,
    int? id,
    Empresa? empresa,
  }) {
    return EmpresaEditarEmProgresso(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj,
      codigoDeAtividade: codigoDeAtividade ?? this.codigoDeAtividade,
      codigoDeNaturezaJuridica:
          codigoDeNaturezaJuridica ?? this.codigoDeNaturezaJuridica,
      email: email ?? this.email,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      nome: nome ?? this.nome,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      regime: regime ?? this.regime,
      registroMunicipal: registroMunicipal ?? this.registroMunicipal,
      substituicaoTributaria:
          substituicaoTributaria ?? this.substituicaoTributaria,
      telefone: telefone ?? this.telefone,
      uf: uf ?? this.uf,
      empresa: empresa ?? this.empresa,
    );
  }
}

class EmpresaSalvarEmProgresso extends EmpresaState {}

class EmpresaSalvarSucesso extends EmpresaState {
  @override
  final Empresa empresa;

  EmpresaSalvarSucesso({required this.empresa});
}

class EmpresaSalvarFalha extends EmpresaState {}
