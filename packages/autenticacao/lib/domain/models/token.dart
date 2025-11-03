import 'package:core/equals.dart';

class Token extends Equatable {
  final String jwtToken;
  final DateTime dataDeCriacao;
  final DateTime dataDeExpiracao;
  final int? idEmpresa;

  const Token({
    required this.jwtToken,
    required this.dataDeCriacao,
    required this.dataDeExpiracao,
    this.idEmpresa,
  });

  @override
  List<Object?> get props => [
        jwtToken,
      ];
}
