part of 'pagamento_avulso_bloc.dart';

abstract class PagamentoAvulsoEvent {}

class PagamentoAvulsoIniciou extends PagamentoAvulsoEvent {}

class PagamentoAvulsoCampoAlterado extends PagamentoAvulsoEvent {
  final String? provider;
  final int? amount;
  final String? description;
  final String? idempotencyKey;
  final String? customerNome;
  final String? customerDocumento;
  final String? customerEmail;
  final String? customerTelefone;

  PagamentoAvulsoCampoAlterado({
    this.provider,
    this.amount,
    this.description,
    this.idempotencyKey,
    this.customerNome,
    this.customerDocumento,
    this.customerEmail,
    this.customerTelefone,
  });
}

class PagamentoAvulsoSalvou extends PagamentoAvulsoEvent {}
