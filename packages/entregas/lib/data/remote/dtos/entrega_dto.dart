import 'package:core/equals.dart';
import 'package:entregas/domain/models/entrega.dart';

class ConfiguracaoEntregaMachineDto extends Equatable
    implements ConfiguracaoEntregaMachine {
  @override
  final String? apiKey;
  @override
  final String? basicAuthUsername;
  @override
  final String? basicAuthPassword;
  @override
  final String ambiente;
  @override
  final String? empresaIdExterno;
  @override
  final String? tipoIdentificacaoEmpresa;
  @override
  final String? identificacaoEmpresa;
  @override
  final int? condutorIdPadrao;

  const ConfiguracaoEntregaMachineDto({
    this.apiKey,
    this.basicAuthUsername,
    this.basicAuthPassword,
    this.ambiente = 'homologacao',
    this.empresaIdExterno,
    this.tipoIdentificacaoEmpresa,
    this.identificacaoEmpresa,
    this.condutorIdPadrao,
  });

  factory ConfiguracaoEntregaMachineDto.fromJson(Map<String, dynamic> json) {
    return ConfiguracaoEntregaMachineDto(
      apiKey: json['apiKey'] as String?,
      basicAuthUsername: json['basicAuthUsername'] as String?,
      basicAuthPassword: json['basicAuthPassword'] as String?,
      ambiente: json['ambiente'] as String? ?? 'homologacao',
      empresaIdExterno: json['empresaIdExterno'] as String?,
      tipoIdentificacaoEmpresa: json['tipoIdentificacaoEmpresa'] as String?,
      identificacaoEmpresa: json['identificacaoEmpresa'] as String?,
      condutorIdPadrao: (json['condutorIdPadrao'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [
        apiKey,
        basicAuthUsername,
        basicAuthPassword,
        ambiente,
        empresaIdExterno,
        tipoIdentificacaoEmpresa,
        identificacaoEmpresa,
        condutorIdPadrao,
      ];
}

class EmpresaIntegracaoEntregaDto extends Equatable
    implements EmpresaIntegracaoEntrega {
  @override
  final int empresaId;
  @override
  final String? provider;
  @override
  final bool ativo;
  @override
  final ConfiguracaoEntregaMachine? configuracao;

  const EmpresaIntegracaoEntregaDto({
    required this.empresaId,
    this.provider,
    required this.ativo,
    this.configuracao,
  });

  factory EmpresaIntegracaoEntregaDto.fromJson(Map<String, dynamic> json) {
    final config = json['configuracao'] as Map<String, dynamic>?;
    return EmpresaIntegracaoEntregaDto(
      empresaId: json['empresaId'] as int,
      provider: json['provider'] as String?,
      ativo: (json['ativo'] as bool?) ?? false,
      configuracao: config != null
          ? ConfiguracaoEntregaMachineDto.fromJson(config)
          : null,
    );
  }

  @override
  List<Object?> get props => [empresaId, provider, ativo];
}

class EstimativaEntregaDto extends Equatable implements EstimativaEntrega {
  @override
  final double valor;
  @override
  final int tempoEstimadoMinutos;
  @override
  final double distanciaKm;

  const EstimativaEntregaDto({
    required this.valor,
    required this.tempoEstimadoMinutos,
    required this.distanciaKm,
  });

  factory EstimativaEntregaDto.fromJson(Map<String, dynamic> json) {
    return EstimativaEntregaDto(
      valor: (json['valor'] as num).toDouble(),
      tempoEstimadoMinutos: (json['tempoEstimadoMinutos'] as num).toInt(),
      distanciaKm: (json['distanciaKm'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [valor, tempoEstimadoMinutos, distanciaKm];
}

class EnderecoEntregaDto extends Equatable implements EnderecoEntrega {
  @override
  final String endereco;
  @override
  final String bairro;
  @override
  final String? complemento;
  @override
  final String cidade;
  @override
  final String estado;
  @override
  final String? referencia;
  @override
  final double lat;
  @override
  final double lng;

  const EnderecoEntregaDto({
    required this.endereco,
    required this.bairro,
    this.complemento,
    required this.cidade,
    required this.estado,
    this.referencia,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'endereco': endereco,
        'bairro': bairro,
        if (complemento != null) 'complemento': complemento,
        'cidade': cidade,
        'estado': estado,
        if (referencia != null) 'referencia': referencia,
        'lat': lat,
        'lng': lng,
      };

  @override
  List<Object?> get props => [endereco, bairro, cidade, estado, lat, lng];
}

class ParadaEntregaDto extends Equatable implements ParadaEntrega {
  @override
  final EnderecoEntrega endereco;
  @override
  final String? idExterno;
  @override
  final String? observacao;
  @override
  final String? nomeCliente;
  @override
  final String? telefoneCliente;
  @override
  final String? codigoConfirmacao;
  @override
  final double? valorCobrar;

  const ParadaEntregaDto({
    required this.endereco,
    this.idExterno,
    this.observacao,
    this.nomeCliente,
    this.telefoneCliente,
    this.codigoConfirmacao,
    this.valorCobrar,
  });

  Map<String, dynamic> toJson() {
    final enderecoDto = endereco as EnderecoEntregaDto;
    return {
      ...enderecoDto.toJson(),
      if (idExterno != null) 'idExterno': idExterno,
      if (observacao != null) 'observacao': observacao,
      if (nomeCliente != null) 'nomeCliente': nomeCliente,
      if (telefoneCliente != null) 'telefoneCliente': telefoneCliente,
      if (codigoConfirmacao != null) 'codigoConfirmacao': codigoConfirmacao,
      if (valorCobrar != null) 'valorCobrar': valorCobrar,
    };
  }

  @override
  List<Object?> get props => [endereco, idExterno, nomeCliente, valorCobrar];
}

class SolicitacaoEntregaDto extends Equatable implements SolicitacaoEntrega {
  @override
  final int id;
  @override
  final String provider;
  @override
  final String status;
  @override
  final double? valorEstimado;
  @override
  final String? enderecoPartidaResumo;
  @override
  final String? enderecoDestinoResumo;
  @override
  final String? motivoCancelamento;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const SolicitacaoEntregaDto({
    required this.id,
    required this.provider,
    required this.status,
    this.valorEstimado,
    this.enderecoPartidaResumo,
    this.enderecoDestinoResumo,
    this.motivoCancelamento,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory SolicitacaoEntregaDto.fromJson(Map<String, dynamic> json) {
    return SolicitacaoEntregaDto(
      id: json['id'] as int,
      provider: json['provider'] as String,
      status: json['status'] as String,
      valorEstimado: (json['valorEstimado'] as num?)?.toDouble(),
      enderecoPartidaResumo: json['enderecoPartidaResumo'] as String?,
      enderecoDestinoResumo: json['enderecoDestinoResumo'] as String?,
      motivoCancelamento: json['motivoCancelamento'] as String?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.tryParse(json['criadoEm'] as String)
          : null,
      atualizadoEm: json['atualizadoEm'] != null
          ? DateTime.tryParse(json['atualizadoEm'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, provider, status, valorEstimado];
}

class RastreioEntregaDto extends Equatable implements RastreioEntrega {
  @override
  final int? paradaId;
  @override
  final String link;
  @override
  final String? codigoConfirmacao;

  const RastreioEntregaDto({
    this.paradaId,
    required this.link,
    this.codigoConfirmacao,
  });

  factory RastreioEntregaDto.fromJson(Map<String, dynamic> json) {
    return RastreioEntregaDto(
      paradaId: (json['paradaId'] as num?)?.toInt(),
      link: json['link'] as String,
      codigoConfirmacao: json['codigoConfirmacao'] as String?,
    );
  }

  @override
  List<Object?> get props => [paradaId, link, codigoConfirmacao];
}
