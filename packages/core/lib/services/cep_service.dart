import 'package:cep_sdk/cep_client.dart';

class CepService {
  Future<EnderecoDoCep> recuperaEnderecoPeloCep(String cep) async {
    final result = await CepClient.getAddress(cep);
    return EnderecoDoCep(
      cep: result.cep,
      logradouro: result.logradouro,
      bairro: result.bairro,
      localidade: result.localidade,
      uf: result.uf,
    );
  }
}

class EnderecoDoCep {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  EnderecoDoCep(
      {required this.cep,
      required this.logradouro,
      required this.bairro,
      required this.localidade,
      required this.uf});

  @override
  String toString() {
    return "$logradouro, $bairro - $localidade/$uf (CEP: $cep)";
  }
}
