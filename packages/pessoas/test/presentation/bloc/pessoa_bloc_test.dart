import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/uses_cases.dart';

import '../../doubles/fakes.dart';
import '../../doubles/use_cases.mocks.dart';

late PessoaBloc pessoaBloc;

final RecuperarPessoa recuperarPessoa = MockRecuperarPessoa();
final SalvarPessoa salvarPessoa = FakeSalvarPessoa();
final CriarPessoa criarPessoa = MockCriarPessoa();
final CriarFuncionario criarFuncionario = MockCriarFuncionario();

class FakeSalvarPessoa implements SalvarPessoa {
  @override
  Future<Pessoa> call({
    required Pessoa pessoa,
    String? nome,
    TipoPessoa? tipoPessoa,
    String? documento,
    String? uf,
    String? inscricaoEstadual,
    DateTime? dataDeNascimento,
    String? email,
    TipoContato? tipoContato,
    String? contato,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    bool? bloqueado,
  }) async =>
      pessoa;
}

void main() {
  setUp(() {
    pessoaBloc = PessoaBloc(
      recuperarPessoa,
      salvarPessoa,
      criarPessoa,
      criarFuncionario,
    );
  });

  var pessoa = fakePessoa(
    id: 1,
    dataDeNascimento: DateTime(2022),
  );

  blocTest<PessoaBloc, PessoaState>(
    'emite estado de sucesso ao carregar pessoa',
    setUp: () {
      _setupRecuperarPessoa(idPessoa: pessoa.id!, response: pessoa);
    },
    build: () => pessoaBloc,
    act: (bloc) => bloc.add(
      PessoaIniciou(
        idPessoa: pessoa.id!,
        tipoPessoa: TipoPessoa.fisica,
      ),
    ),
    expect: () => [
      isA<PessoaState>()
          .having((s) => s.pessoaStep, 'pessoaStep', PessoaStep.carregando),
      PessoaState.fromModel(pessoa),
    ],
  );
  blocTest<PessoaBloc, PessoaState>(
    'emite estado de sucesso ao editar pessoa',
    setUp: () {},
    build: () => pessoaBloc,
    seed: () => PessoaState(
      pessoaStep: PessoaStep.editando,
    ),
    act: (bloc) => bloc.add(PessoaEditou(
      bloqueado: pessoa.bloqueado,
      contato: pessoa.contato,
      documento: pessoa.documento,
      eCliente: pessoa.eCliente,
      eFornecedor: pessoa.eFornecedor,
      email: pessoa.email,
      inscricaoEstadual: pessoa.inscricaoEstadual,
      nome: pessoa.nome,
      tipoContato: pessoa.tipoContato,
      tipoPessoa: pessoa.tipoPessoa,
      uf: pessoa.uf,
      eFuncionario: pessoa.eFuncionario,
      dataDeNascimento: pessoa.dataDeNascimento,
    )),
    expect: () {
      var lastState = PessoaState.fromModel(pessoa);
      return [
        lastState.copyWith(
          pessoaStep: PessoaStep.editando,
        )
      ];
    },
  );

  blocTest<PessoaBloc, PessoaState>(
    'emite estado de sucesso após SALVAR pessoa',
    build: () => pessoaBloc,
    act: (bloc) => bloc.add(PessoaSalvou()),
    seed: () {
      var state = PessoaState.fromModel(pessoa);
      return state.copyWith(
        pessoaStep: PessoaStep.editando,
      );
    },
    expect: () => [
      PessoaState.fromModel(pessoa, step: PessoaStep.carregando),
      PessoaState.fromModel(pessoa, step: PessoaStep.salva),
    ],
  );
}

void _setupRecuperarPessoa({
  required int idPessoa,
  required Pessoa? response,
}) {
  when(recuperarPessoa.call(idPessoa: idPessoa)).thenAnswer(
    (_) async => response,
  );
}
