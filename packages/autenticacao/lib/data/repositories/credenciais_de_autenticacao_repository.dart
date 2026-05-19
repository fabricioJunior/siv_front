import 'package:autenticacao/domain/data/repositories/i_credenciais_de_autenticacao_repository.dart';
import 'package:autenticacao/domain/models/credenciais_de_autenticacao.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';

class CredenciaisDeAutenticacaoRepository
    implements ICredenciaisDeAutenticacaoRepository {
  static const String _fileName = '.auth_credentials_v1.json';
  static const String _pepper = 'siv_front_auth_credentials_v1';

  const CredenciaisDeAutenticacaoRepository();

  @override
  Future<void> salvar(CredenciaisDeAutenticacao credenciais) async {
    final file = await _credentialsFile();
    final secretKey = await _deriveSecretKey();
    final algorithm = AesGcm.with256bits();
    final nonce = _randomBytes(12);

    final plainText = utf8.encode(
      jsonEncode({
        'usuario': credenciais.usuario,
        'senha': credenciais.senha,
      }),
    );

    final box = await algorithm.encrypt(
      plainText,
      secretKey: secretKey,
      nonce: nonce,
    );

    final encryptedPayload = {
      'n': base64Encode(box.nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    };

    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(encryptedPayload), flush: true);
  }

  @override
  Future<CredenciaisDeAutenticacao?> recuperar() async {
    final file = await _credentialsFile();
    if (!await file.exists()) {
      return null;
    }

    try {
      final payload = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final nonce = base64Decode(payload['n'] as String);
      final cipherText = base64Decode(payload['c'] as String);
      final macBytes = base64Decode(payload['m'] as String);

      final secretKey = await _deriveSecretKey();
      final algorithm = AesGcm.with256bits();
      final box = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

      final decrypted = await algorithm.decrypt(box, secretKey: secretKey);
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
    final file = await _credentialsFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _credentialsFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<SecretKey> _deriveSecretKey() async {
    final material = utf8.encode(
      '$_pepper|${Platform.operatingSystem}|${Platform.localHostname}|${Platform.operatingSystemVersion}',
    );
    final digest = await Sha256().hash(material);
    return SecretKey(digest.bytes);
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}