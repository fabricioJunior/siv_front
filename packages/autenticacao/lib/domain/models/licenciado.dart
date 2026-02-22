import 'package:core/equals.dart';

class Licenciado extends Equatable {
  final String id;
  final String nome;
  final String urlApi;

  const Licenciado({
    required this.id,
    required this.nome,
    required this.urlApi,
  });

  @override
  List<Object?> get props => [id, nome, urlApi];
}
