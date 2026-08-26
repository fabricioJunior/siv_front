import 'package:core/hive_anotacoes.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
//
// Guarda só o payload já criptografado (AES-GCM) das credenciais salvas --
// mesmo formato do arquivo usado no lado nativo (io), trocando apenas o
// destino (arquivo -> box Hive). Uma entrada só por device (chave fixa).
class CredenciaisHiveDto with HiveDto<CredenciaisHiveDto>, StorageEntity {
  static const int chaveUnica = 0;

  final String nonce;
  final String cipherText;
  final String mac;

  CredenciaisHiveDto({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  @override
  int get dataBaseId => chaveUnica;

  @override
  Map<String, dynamic> get storageProperties => {
    'nonce': nonce,
    'cipherText': cipherText,
    'mac': mac,
  };

  static CredenciaisHiveDto fromStorage(Map<String, dynamic> props) {
    return CredenciaisHiveDto(
      nonce: props['nonce'] as String,
      cipherText: props['cipherText'] as String,
      mac: props['mac'] as String,
    );
  }
}
