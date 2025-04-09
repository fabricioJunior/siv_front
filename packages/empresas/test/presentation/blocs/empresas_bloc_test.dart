import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:empresas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/bloc_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/use_cases.mocks.dart';

final RecuperarEmpresas recuperarEmpresas = MockRecuperarEmpresas();

late EmpresasBloc empresasBloc;
void main() {
  setUp(() {
    empresasBloc = EmpresasBloc(
      recuperarEmpresas,
    );
  });

  group('empresas bloc', () {
    var empresa1 = fakeEmpresa(
      id: 1,
    );
    var empresa2 = fakeEmpresa(
      id: 2,
    );

    var empresas = [empresa1, empresa2];
    blocTest<EmpresasBloc, EmpresasState>(
      'emite estado de sucesso após carregar empresas',
      build: () => empresasBloc,
      setUp: () {
        _setupRecuperarEmpresas(empresas);
      },
      act: (bloc) {
        bloc.add(EmpresasIniciou());
      },
      expect: () => [
        EmpresasCarregarEmProgresso(),
        EmpresasCarregarSucesso(empresas: empresas)
      ],
    );
  });
}

void _setupRecuperarEmpresas(List<Empresa> empresas) {
  when(recuperarEmpresas.call()).thenAnswer((_) async => empresas);
}
