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
final SalvarPessoa salvarPessoa = MockSalvarPessoa();
final CriarPessoa criarPessoa = MockCriarPessoa();

void main() {
  setUp(() {
    pessoaBloc = PessoaBloc(
      recuperarPessoa,
      salvarPessoa,
      criarPessoa,
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
      PessoaState(pessoaStep: PessoaStep.carregado),
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
    setUp: () {
      _setupSalvarPessoa(pessoa: pessoa);
    },
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
    verify: (bloc) {
      verify(salvarPessoa.call(pessoa: pessoa));
    },
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

void _setupSalvarPessoa({
  required Pessoa pessoa,
}) {
  when(salvarPessoa.call(pessoa: pessoa)).thenAnswer(
    (_) async => pessoa,
  );
}

void _setupCriarPessoa({
  required Pessoa response,
}) {
  when(
    criarPessoa.call(
      dataDeNascimento: response.dataDeNascimento!,
      bloqueado: response.bloqueado,
      contato: response.contato,
      documento: response.documento,
      eCliente: response.eCliente,
      eFornecedor: response.eFornecedor,
      eFuncionario: response.eFuncionario,
      email: response.email,
      nome: response.nome,
      tipoContato: response.tipoContato,
      tipoPessoa: response.tipoPessoa,
      uf: response.uf!,
    ),
  ).thenAnswer(
    (_) async => response,
  );
}
