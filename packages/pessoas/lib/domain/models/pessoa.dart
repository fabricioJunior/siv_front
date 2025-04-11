mixin Pessoa {
  int get id;
  String get nome;
  TipoPessoa get tipoPessoa;
  String get documento;
  String get uf;
  String? get inscricaoEstadual;
  DateTime? dataDeNascimento;
  String get email;
  TipoContato get tipoContato;
  String get contato;
  bool get eCliente;
  bool get eFornecedor;
  bool get eFuncionario;
  bool get bloqueado;

  static Pessoa instance({
    required int id,
    bool bloqueado = false,
    required String contato,
    required String documento,
    required bool eCliente,
    required bool eFornecedor,
    required bool eFuncionario,
    required String email,
    required String nome,
    required TipoContato tipoContato,
    required TipoPessoa tipoPessoa,
    String? inscricaoEstadual,
    required String uf,
  }) =>
      _Pessoa(
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
      );
}

class _Pessoa with Pessoa {
  @override
  final bool bloqueado;

  @override
  final String contato;

  @override
  final String documento;

  @override
  final bool eCliente;

  @override
  final bool eFornecedor;

  @override
  final bool eFuncionario;

  @override
  final String email;

  @override
  final int id;

  @override
  final String? inscricaoEstadual;

  @override
  final String nome;

  @override
  final TipoContato tipoContato;

  @override
  final TipoPessoa tipoPessoa;

  @override
  final String uf;

  _Pessoa({
    required this.id,
    required this.bloqueado,
    required this.contato,
    required this.documento,
    required this.eCliente,
    required this.eFornecedor,
    required this.eFuncionario,
    required this.email,
    required this.nome,
    required this.tipoContato,
    required this.tipoPessoa,
    required this.inscricaoEstadual,
    required this.uf,
  });
}

enum TipoContato {
  telefone,
  celular,
  whatsApp,
  telegram,
}

enum TipoPessoa {
  fisica,
  juridica,
}
