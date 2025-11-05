import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

import '../../../presentation.dart';
import '../../doubles/fakes.dart';
import '../../doubles/use_cases.mocks.dart';

final RecuperarPessoas recuperarPessoas = MockRecuperarPessoas();

late PessoasBloc pessoasBloc;

var pessoa = fakePessoa(id: 1);
var pessoa1 = fakePessoa(
  id: 2,
);

var pessoas = [pessoa, pessoa1];
void main() {
  setUp(() {
    pessoasBloc = PessoasBloc(
      recuperarPessoas,
    );
  });

  blocTest<PessoasBloc, PessoasState>(
    'emits  sucesso when PessoasIniciou is added.',
    build: () => pessoasBloc,
    setUp: () {
      _setupRecuperarPessoas(pessoas: pessoas);
    },
    act: (bloc) => bloc.add(PessoasIniciou()),
    expect: () => <PessoasState>[
      PessoasCarregarEmProgresso(),
      PessoasCarregarSucesso(
        pessoas: pessoas,
        pagina: 0,
      )
    ],
  );
}

void _setupRecuperarPessoas({
  required List<Pessoa> pessoas,
}) {
  when(recuperarPessoas.call()).thenAnswer((_) async => pessoas);
}
