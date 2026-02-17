import 'package:produtos/models.dart';

Tamanho fakeTamanho({int? id = 1, String nome = 'P', bool inativo = false}) {
  return Tamanho.instance(id: id, nome: nome, inativo: inativo);
}

Cor fakeCor({int? id = 1, String nome = 'Vermelho', bool inativo = false}) {
  return Cor.instance(id: id, nome: nome, inativo: inativo);
}
