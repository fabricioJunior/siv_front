import 'package:core/equals.dart';

abstract class EmpresaIntegracaoEntrega implements Equatable {
  int get empresaId;
  String? get provider;
  bool get ativo;
  ConfiguracaoEntregaMachine? get configuracao;
}

/// Campos sensíveis (`apiKey`, `basicAuthPassword`) chegam mascarados
/// (`'***'`) quando já existe configuração salva — nunca exibir/editar como
/// se fosse o valor real.
abstract class ConfiguracaoEntregaMachine implements Equatable {
  String? get apiKey;
  String? get basicAuthUsername;
  String? get basicAuthPassword;
  String get ambiente;
  String? get empresaIdExterno;
  String? get tipoIdentificacaoEmpresa;
  String? get identificacaoEmpresa;
  int? get condutorIdPadrao;
}

abstract class EstimativaEntrega implements Equatable {
  double get valor;
  int get tempoEstimadoMinutos;
  double get distanciaKm;
}

abstract class EnderecoEntrega implements Equatable {
  String get endereco;
  String get bairro;
  String? get complemento;
  String get cidade;
  String get estado;
  String? get referencia;
  double get lat;
  double get lng;
}

abstract class ParadaEntrega implements Equatable {
  EnderecoEntrega get endereco;
  String? get idExterno;
  String? get observacao;
  String? get nomeCliente;
  String? get telefoneCliente;
  String? get codigoConfirmacao;
  double? get valorCobrar;
}

abstract class SolicitacaoEntrega implements Equatable {
  int get id;
  String get provider;
  String get status;
  double? get valorEstimado;
  String? get enderecoPartidaResumo;
  String? get enderecoDestinoResumo;
  String? get motivoCancelamento;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
}

abstract class RastreioEntrega implements Equatable {
  int? get paradaId;
  String get link;
  String? get codigoConfirmacao;
}

/// Status brutos retornados pelo provider — traduzir para exibição.
String descricaoStatusEntrega(String status) {
  switch (status) {
    case 'D':
      return 'Distribuindo';
    case 'G':
      return 'Aguardando aceite';
    case 'A':
      return 'Aceita';
    case 'E':
      return 'Em andamento';
    case 'F':
      return 'Finalizada';
    case 'N':
      return 'Não atendida';
    case 'C':
      return 'Cancelada';
    case 'P':
      return 'Pendente';
    case 'L':
      return 'Aguardando liberação';
    default:
      return status;
  }
}
