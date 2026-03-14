part of 'pagamento_avulso_bloc.dart';

class PagamentoAvulsoState extends Equatable {
  final String? provider;
  final int? amount;
  final String? description;
  final String? idempotencyKey;
  final String? customerNome;
  final String? customerDocumento;
  final String? customerEmail;
  final String? customerTelefone;
  final PagamentoAvulso? pagamento;
  final String? erro;
  final PagamentoAvulsoStep step;

  const PagamentoAvulsoState({
    this.provider,
    this.amount,
    this.description,
    this.idempotencyKey,
    this.customerNome,
    this.customerDocumento,
    this.customerEmail,
    this.customerTelefone,
    this.pagamento,
    this.erro,
    required this.step,
  });

  PagamentoAvulsoState copyWith({
    String? provider,
    int? amount,
    String? description,
    String? idempotencyKey,
    String? customerNome,
    String? customerDocumento,
    String? customerEmail,
    String? customerTelefone,
    PagamentoAvulso? pagamento,
    String? erro,
    PagamentoAvulsoStep? step,
  }) {
    return PagamentoAvulsoState(
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      customerNome: customerNome ?? this.customerNome,
      customerDocumento: customerDocumento ?? this.customerDocumento,
      customerEmail: customerEmail ?? this.customerEmail,
      customerTelefone: customerTelefone ?? this.customerTelefone,
      pagamento: pagamento ?? this.pagamento,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        provider,
        amount,
        description,
        idempotencyKey,
        customerNome,
        customerDocumento,
        customerEmail,
        customerTelefone,
        pagamento,
        erro,
        step,
      ];
}

enum PagamentoAvulsoStep {
  inicial,
  editando,
  validacaoInvalida,
  salvando,
  salvo,
  falha,
}
