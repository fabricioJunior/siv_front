import 'dart:convert';
import 'dart:math';

import 'package:autenticacao/data/local/dtos/credenciais_hive_dto.dart';
import 'package:autenticacao/domain/data/repositories/i_credenciais_de_autenticacao_repository.dart';
import 'package:autenticacao/domain/models/credenciais_de_autenticacao.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:cryptography/cryptography.dart';
import 'package:idb_shim/idb_shim.dart';

const _storeName = 'autenticacao_CredenciaisHiveDto';

class CredenciaisDeAutenticacaoRepository
    implements ICredenciaisDeAutenticacaoRepository {
  // Mesmo pepper do lado nativo. No web não dá pra compor com
  // Platform.operatingSystem/localHostname (não existe equivalente estável
  // sem trazer dependência nova só pra isso) -- fica só o pepper fixo.
  // ponytail: sem componente de device fingerprint no web, upgrade se
  // precisar de mais entropia por device depois.
  static const String _pepper = 'siv_front_auth_credentials_v1';

  const CredenciaisDeAutenticacaoRepository();

  @override
  Future<void> salvar(CredenciaisDeAutenticacao credenciais) async {
    final secretKey = await _deriveSecretKey();
    final algorithm = AesGcm.with256bits();
    final nonce = _randomBytes(12);

    final plainText = utf8.encode(
      jsonEncode({
        'usuario': credenciais.usuario,
        'senha': credenciais.senha,
      }),
    );

    final encryptedBox = await algorithm.encrypt(
      plainText,
      secretKey: secretKey,
      nonce: nonce,
    );

    final dto = CredenciaisHiveDto(
      nonce: base64Encode(encryptedBox.nonce),
      cipherText: base64Encode(encryptedBox.cipherText),
      mac: base64Encode(encryptedBox.mac.bytes),
    );

    final db = await sl<IIndexedDbDatabaseInstance>().getDatabase();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    await txn
        .objectStore(_storeName)
        .put(dto.storageProperties, CredenciaisHiveDto.chaveUnica);
    await txn.completed;
  }

  @override
  Future<CredenciaisDeAutenticacao?> recuperar() async {
    final db = await sl<IIndexedDbDatabaseInstance>().getDatabase();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final raw =
        await txn.objectStore(_storeName).getObject(CredenciaisHiveDto.chaveUnica);
    await txn.completed;
    if (raw == null) {
      return null;
    }
    final payload = CredenciaisHiveDto.fromStorage(
      Map<String, dynamic>.from(raw as Map),
    );

    try {
      final nonce = base64Decode(payload.nonce);
      final cipherText = base64Decode(payload.cipherText);
      final macBytes = base64Decode(payload.mac);

      final secretKey = await _deriveSecretKey();
      final algorithm = AesGcm.with256bits();
      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

      final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
      final data = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;

      final usuario = (data['usuario'] as String?)?.trim();
      final senha = data['senha'] as String?;
      if (usuario == null || usuario.isEmpty || senha == null) {
        return null;
      }

      return CredenciaisDeAutenticacao(usuario: usuario, senha: senha);
    } catch (_) {
      await limpar();
      return null;
    }
  }

  @override
  Future<void> limpar() async {
    final db = await sl<IIndexedDbDatabaseInstance>().getDatabase();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    await txn.objectStore(_storeName).delete(CredenciaisHiveDto.chaveUnica);
    await txn.completed;
  }

  Future<SecretKey> _deriveSecretKey() async {
    final digest = await Sha256().hash(utf8.encode(_pepper));
    return SecretKey(digest.bytes);
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
