part of 'ecommerce_chaves_mcp_bloc.dart';

abstract class EcommerceChavesMcpEvent extends Equatable {
  const EcommerceChavesMcpEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceChavesMcpIniciou extends EcommerceChavesMcpEvent {
  final int ecommerceId;

  const EcommerceChavesMcpIniciou({required this.ecommerceId});

  @override
  List<Object?> get props => [ecommerceId];
}

/// O resultado (com a chave em claro) volta só por [resposta]: sucesso com o
/// resultado, falha com `String` (mensagem da API). Nunca entra no state.
class EcommerceChaveMcpCriou extends EcommerceChavesMcpEvent {
  final String nome;
  final List<String> escopos;
  final DateTime? expiraEm;
  final Completer<CriarChaveMcpResultado> resposta;

  const EcommerceChaveMcpCriou({
    required this.nome,
    required this.escopos,
    this.expiraEm,
    required this.resposta,
  });

  @override
  List<Object?> get props => [nome, escopos, expiraEm, resposta];
}

/// [resposta] falha com `String` (mensagem da API).
class EcommerceChaveMcpRevogou extends EcommerceChavesMcpEvent {
  final int chaveId;
  final Completer<EcommerceChaveMcp> resposta;

  const EcommerceChaveMcpRevogou({required this.chaveId, required this.resposta});

  @override
  List<Object?> get props => [chaveId, resposta];
}
