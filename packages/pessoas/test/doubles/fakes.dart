import 'package:pessoas/models.dart';

Pessoa fakePessoa({
  int id = 1,
  String nome = 'Nome Teste',
  TipoPessoa tipoPessoa = TipoPessoa.fisica,
  String documento = '00000000000',
  String uf = 'SP',
  String? inscricaoEstadual,
  DateTime? dataDeNascimento,
  String email = 'teste@example.com',
  TipoContato tipoContato = TipoContato.telefone,
  String contato = '11999999999',
  bool eCliente = true,
  bool eFornecedor = false,
  bool eFuncionario = false,
  bool bloqueado = false,
}) {
  return Pessoa.instance(
    id: id,
    bloqueado: bloqueado,
    contato: contato,
    documento: documento,
    eCliente: eCliente,
    eFornecedor: eFornecedor,
    eFuncionario: eFuncionario,
    email: email,
    nome: nome,
    tipoContato: tipoContato,
    tipoPessoa: tipoPessoa,
    inscricaoEstadual: inscricaoEstadual,
    uf: uf,
    dataDeNascimento: dataDeNascimento,
  );
}

Ponto fakePonto({
  int valor = 10,
  DateTime? validade,
  String descricao = 'Ponto de teste',
  DateTime? dtCriacao,
  bool cancelado = false,
  String? motivoCancelamento,
  DateTime? dtCancelamento,
  int id = 1,
}) {
  final validadeNonNull =
      validade ?? DateTime.now().add(const Duration(days: 30));
  final dtCriacaoNonNull = dtCriacao ?? DateTime.now();
  return Ponto.instance(
    id: id,
    valor: valor,
    validade: validadeNonNull,
    descricao: descricao,
    dtCriacao: dtCriacaoNonNull,
    cancelado: cancelado,
    motivoCancelamento: motivoCancelamento,
    dtCancelamento: dtCancelamento,
  );
}
