import 'package:core/seletores/i_seletor.dart';

class DadoInicial implements SelectData {
  @override
  final int id;

  @override
  final String nome;

  @override
  final Map<String, dynamic> data;

  DadoInicial({required this.id, required this.nome, required this.data});
}
