part of 'endereco_cadastro_bloc.dart';

enum EtapaCadastroEndereco {
  cep,
  dadosBasicos, // logradouro, número, complemento, bairro
  uf,
  municipio,
  tipo,
  confirmacao,
}

abstract class EnderecoCadastroState {
  final EtapaCadastroEndereco etapa;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? uf;
  final String? municipio;
  final TipoEndereco? tipo;
  final bool principal;
  final bool preenchimentoManual;

  EnderecoCadastroState({
    required this.etapa,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.uf,
    this.municipio,
    this.tipo,
    this.principal = false,
    this.preenchimentoManual = false,
  });

  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  });
}

class EnderecoCadastroInicial extends EnderecoCadastroState {
  EnderecoCadastroInicial()
      : super(
          etapa: EtapaCadastroEndereco.cep,
        );

  @override
  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  }) {
    return EnderecoCadastroEmProgresso(
      etapa: etapa ?? this.etapa,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      tipo: tipo ?? this.tipo,
      principal: principal ?? this.principal,
      preenchimentoManual: preenchimentoManual ?? this.preenchimentoManual,
    );
  }
}

class EnderecoCadastroEmProgresso extends EnderecoCadastroState {
  EnderecoCadastroEmProgresso({
    required super.etapa,
    super.cep,
    super.logradouro,
    super.numero,
    super.complemento,
    super.bairro,
    super.uf,
    super.municipio,
    super.tipo,
    super.principal,
    super.preenchimentoManual,
  });

  @override
  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  }) {
    return EnderecoCadastroEmProgresso(
      etapa: etapa ?? this.etapa,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      tipo: tipo ?? this.tipo,
      principal: principal ?? this.principal,
      preenchimentoManual: preenchimentoManual ?? this.preenchimentoManual,
    );
  }
}

class EnderecoCadastroBuscandoCep extends EnderecoCadastroState {
  EnderecoCadastroBuscandoCep({
    required String cep,
  }) : super(
          etapa: EtapaCadastroEndereco.cep,
          cep: cep,
        );

  @override
  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  }) {
    return EnderecoCadastroEmProgresso(
      etapa: etapa ?? this.etapa,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      tipo: tipo ?? this.tipo,
      principal: principal ?? this.principal,
      preenchimentoManual: preenchimentoManual ?? this.preenchimentoManual,
    );
  }
}

class EnderecoCadastroErroCep extends EnderecoCadastroState {
  final String mensagem;

  EnderecoCadastroErroCep({
    required this.mensagem,
    required String cep,
  }) : super(
          etapa: EtapaCadastroEndereco.cep,
          cep: cep,
        );

  @override
  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  }) {
    return EnderecoCadastroEmProgresso(
      etapa: etapa ?? this.etapa,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      tipo: tipo ?? this.tipo,
      principal: principal ?? this.principal,
      preenchimentoManual: preenchimentoManual ?? this.preenchimentoManual,
    );
  }
}

class EnderecoCadastroConfirmado extends EnderecoCadastroState {
  final Endereco endereco;

  EnderecoCadastroConfirmado({
    required this.endereco,
  }) : super(
          etapa: EtapaCadastroEndereco.confirmacao,
          cep: endereco.cep,
          logradouro: endereco.logradouro,
          numero: endereco.numero,
          complemento: endereco.complemento,
          bairro: endereco.bairro,
          uf: endereco.uf,
          municipio: endereco.municipio,
          tipo: endereco.tipoEndereco,
          principal: endereco.principal,
        );

  @override
  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  }) {
    return EnderecoCadastroEmProgresso(
      etapa: etapa ?? this.etapa,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      tipo: tipo ?? this.tipo,
      principal: principal ?? this.principal,
      preenchimentoManual: preenchimentoManual ?? this.preenchimentoManual,
    );
  }
}

class EnderecoCadastroCancelado extends EnderecoCadastroState {
  EnderecoCadastroCancelado()
      : super(
          etapa: EtapaCadastroEndereco.cep,
        );

  @override
  EnderecoCadastroState copyWith({
    EtapaCadastroEndereco? etapa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? uf,
    String? municipio,
    TipoEndereco? tipo,
    bool? principal,
    bool? preenchimentoManual,
  }) {
    return EnderecoCadastroInicial();
  }
}
