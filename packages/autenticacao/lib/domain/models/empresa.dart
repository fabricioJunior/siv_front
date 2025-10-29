mixin Empresa {
  int get id;
  String get nome;

  static Empresa instance({
    required int id,
    required String nome,
  }) =>
      _Empresa(
        id: id,
        nome: nome,
      );
}

class _Empresa implements Empresa {
  @override
  final int id;

  @override
  final String nome;

  _Empresa({
    required this.id,
    required this.nome,
  });
}
