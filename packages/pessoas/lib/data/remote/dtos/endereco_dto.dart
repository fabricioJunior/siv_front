import 'package:pessoas/models.dart';

class EnderecoDto implements Endereco {
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

  EnderecoDto({
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

  factory EnderecoDto.fromJson(Map<String, dynamic> json) {
    return EnderecoDto(
      id: (json['id'] as num?)?.toInt(),
      principal: json['principal'] == true,
      tipoEndereco: tipoEnderecoFromJson(json['tipoEndereco']),
      cep: (json['cep'] ?? '').toString(),
      logradouro: (json['logradouro'] ?? '').toString(),
      numero: (json['numero'] ?? '').toString(),
      complemento: (json['complemento'] ?? '').toString(),
      bairro: (json['bairro'] ?? '').toString(),
      municipio: (json['municipio'] ?? '').toString(),
      uf: (json['uf'] ?? '').toString(),
      pais: (json['pais'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'principal': principal,
      'tipoEndereco': tipoEnderecoToJson(tipoEndereco),
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'municipio': municipio,
      'uf': uf,
      'pais': pais,
    };
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

TipoEndereco tipoEnderecoFromJson(dynamic value) {
  final normalized = (value ?? '').toString().toLowerCase().trim();
  if (normalized == 'comercial') return TipoEndereco.comercial;
  if (normalized == 'residencial') return TipoEndereco.residencial;
  return TipoEndereco.comercial;
}

String tipoEnderecoToJson(TipoEndereco value) {
  switch (value) {
    case TipoEndereco.comercial:
      return 'Comercial';
    case TipoEndereco.residencial:
      return 'Residencial';
  }
}

extension EnderecoToDto on Endereco {
  EnderecoDto toDto() {
    return EnderecoDto(
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
}
