import 'package:core/equals.dart';

class Token extends Equatable {
  final String jwtToken;
  final DateTime dataDeCriacao;
  final DateTime dataDeExpiracao;

  const Token({
    required this.jwtToken,
    required this.dataDeCriacao,
    required this.dataDeExpiracao,
  });

  @override
  List<Object?> get props => [
        jwtToken,
      ];
}
