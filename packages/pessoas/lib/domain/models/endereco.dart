import 'package:core/equals.dart';

abstract class Endereco implements Equatable {
  int? get id;
  bool get principal;
  TipoEndereco get tipoEndereco;
  String get cep;
  String get logradouro;
  String get numero;
  String get complemento;
  String get bairro;
  String get municipio;
  String get uf;
  String get pais;

  factory Endereco.create({
    int? id,
    required bool principal,
    required TipoEndereco tipoEndereco,
    required String cep,
    required String logradouro,
    required String numero,
    required String complemento,
    required String bairro,
    required String municipio,
    required String uf,
    required String pais,
  }) = _EnderecoImpl;

  @override
  List<Object?> get props => [
        id,
        principal,
        tipoEndereco,
        cep,
        logradouro,
        numero,
        complemento,
        bairro,
        municipio,
        uf,
        pais,
      ];

  @override
  bool? get stringify => true;
}

class _EnderecoImpl implements Endereco {
  @override
  final int? id;
  @override
  final bool principal;
  @override
  final TipoEndereco tipoEndereco;
  @override
  final String cep;
  @override
  final String logradouro;
  @override
  final String numero;
  @override
  final String complemento;
  @override
  final String bairro;
  @override
  final String municipio;
  @override
  final String uf;
  @override
  final String pais;

  _EnderecoImpl({
    this.id,
    required this.principal,
    required this.tipoEndereco,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.municipio,
    required this.uf,
    required this.pais,
  });

  _EnderecoImpl copyWith({
    int? id,
    bool? principal,
    TipoEndereco? tipoEndereco,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? municipio,
    String? uf,
    String? pais,
  }) {
    return _EnderecoImpl(
      id: id ?? this.id,
      principal: principal ?? this.principal,
      tipoEndereco: tipoEndereco ?? this.tipoEndereco,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      municipio: municipio ?? this.municipio,
      uf: uf ?? this.uf,
      pais: pais ?? this.pais,
    );
  }

  @override
  List<Object?> get props => [
        id,
        principal,
        tipoEndereco,
        cep,
        logradouro,
        numero,
        complemento,
        bairro,
        municipio,
        uf,
        pais,
      ];

  @override
  bool? get stringify => true;
}

extension EnderecoCopyWith on Endereco {
  Endereco copyWith({
    int? id,
    bool? principal,
    TipoEndereco? tipoEndereco,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? municipio,
    String? uf,
    String? pais,
  }) {
    if (this is _EnderecoImpl) {
      return (this as _EnderecoImpl).copyWith(
        id: id,
        principal: principal,
        tipoEndereco: tipoEndereco,
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        municipio: municipio,
        uf: uf,
        pais: pais,
      );
    }

    return Endereco.create(
      id: id ?? this.id,
      principal: principal ?? this.principal,
      tipoEndereco: tipoEndereco ?? this.tipoEndereco,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      municipio: municipio ?? this.municipio,
      uf: uf ?? this.uf,
      pais: pais ?? this.pais,
    );
  }
}

enum TipoEndereco {
  comercial,
  residencial,
}
