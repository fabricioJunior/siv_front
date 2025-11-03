import 'package:pessoas/domain/data/data_sourcers/remote/i_pessoas_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/domain/models/pessoa.dart';

class PessoasRepository implements IPessoasRepository {
  final IPessoasRemoteDataSource remoteDataSource;

  PessoasRepository({required this.remoteDataSource});
  @override
  Future<Pessoa?> recuperarPessoa(int id) {
    return remoteDataSource.getPessoa(id);
  }

  @override
  Future<Pessoa?> recuperarPessoaPeloDocumento(String documento) {
    return remoteDataSource.recuperarPessoaPorDocumento(documento);
  }

  @override
  Future<Iterable<Pessoa>> recuperarPessoas() {
    return remoteDataSource.getPessoas();
  }

  @override
  Future<Pessoa> salvarPessoa(Pessoa pessoa) {
    return remoteDataSource.atualizarPessoa(pessoa);
  }

  @override
  Future<Pessoa> novaPessoa(
      {required bool bloqueado,
      required String contato,
      required String documento,
      required bool eCliente,
      required bool eFornecedor,
      required bool eFuncionario,
      required String email,
      String? inscricaoEstadual,
      required String nome,
      required TipoContato tipoContato,
      required TipoPessoa tipoPessoa,
      required String uf}) {
    return remoteDataSource.criarPessoa(
      bloqueado: bloqueado,
      contato: contato,
      documento: documento,
      eCliente: eCliente,
      eFornecedor: eFornecedor,
      eFuncionario: eFuncionario,
      email: email,
      nome: nome,
      tipoContato: tipoContato,
      tipoPessoa: tipoPessoa,
      uf: uf,
    );
  }
}
