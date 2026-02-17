import 'package:produtos/models.dart';
import 'package:produtos/data/remote/dtos/tamanho_dto.dart';
import 'package:produtos/data/remote/dtos/cor_dto.dart';

Tamanho fakeTamanho({int? id = 1, String nome = 'P', bool inativo = false}) {
  return TamanhoDto(id: id, nome: nome, inativo: inativo);
}

Cor fakeCor({int? id = 1, String nome = 'Vermelho', bool inativo = false}) {
  return CorDto(id: id, nome: nome, inativo: inativo);
}
