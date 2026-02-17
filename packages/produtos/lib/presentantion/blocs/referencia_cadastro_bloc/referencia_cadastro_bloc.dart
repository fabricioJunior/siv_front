import 'dart:async';
import 'dart:math';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'referencia_cadastro_event.dart';
part 'referencia_cadastro_state.dart';

class ReferenciaCadastroBloc
    extends Bloc<ReferenciaCadastroEvent, ReferenciaCadastroState> {
  final RecuperarCategorias _recuperarCategorias;
  final RecuperarSubCategorias _recuperarSubCategorias;

  ReferenciaCadastroBloc(
    this._recuperarCategorias,
    this._recuperarSubCategorias,
  ) : super(const ReferenciaCadastroState()) {
    on<ReferenciaCadastroIniciou>(_onIniciou);
    on<ReferenciaCadastroCategoriaSelecionada>(_onCategoriaSelecionada);
    on<ReferenciaCadastroSubCategoriaSelecionada>(_onSubCategoriaSelecionada);
    on<ReferenciaCadastroIdAlterado>(_onIdAlterado);
    on<ReferenciaCadastroGerarId>(_onGerarId);
    on<ReferenciaCadastroGerarNome>(_onGerarNome);
    on<ReferenciaCadastroNomeAlterado>(_onNomeAlterado);
    on<ReferenciaCadastroProximo>(_onProximo);
    on<ReferenciaCadastroVoltar>(_onVoltar);
    on<ReferenciaCadastroReiniciar>(_onReiniciar);
  }

  FutureOr<void> _onIniciou(
    ReferenciaCadastroIniciou event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    try {
      emit(state.copyWith(carregandoCategorias: true, mensagem: null));
      final categorias = await _recuperarCategorias.call();
      categorias.sort((a, b) => a.nome.compareTo(b.nome));
      emit(
        state.copyWith(
          carregandoCategorias: false,
          categorias: categorias,
          step: ReferenciaCadastroStep.categoria,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(carregandoCategorias: false, mensagem: 'Falha'));
      addError(e, s);
    }
  }

  FutureOr<void> _onCategoriaSelecionada(
    ReferenciaCadastroCategoriaSelecionada event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    emit(
      state.copyWith(
        categoria: event.categoria,
        subCategoria: null,
        subCategorias: const [],
        carregandoSubCategorias: false,
        referenciaId: null,
        nome: null,
        step: ReferenciaCadastroStep.categoria,
        mensagem: null,
      ),
    );

    final categoriaId = event.categoria.id;
    if (categoriaId == null) {
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          mensagem: 'Categoria invalida',
        ),
      );
      return;
    }

    try {
      final subCategorias = await _recuperarSubCategorias.call(
        categoriaId,
        inativa: false,
      );
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          subCategorias: subCategorias,
          step: ReferenciaCadastroStep.categoria,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          mensagem: 'Falha ao carregar sub-categorias',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onSubCategoriaSelecionada(
    ReferenciaCadastroSubCategoriaSelecionada event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    emit(state.copyWith(subCategoria: event.subCategoria, mensagem: null));
  }

  FutureOr<void> _onIdAlterado(
    ReferenciaCadastroIdAlterado event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    emit(state.copyWith(referenciaId: event.id, mensagem: null));
  }

  FutureOr<void> _onGerarId(
    ReferenciaCadastroGerarId event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    final categoriaId = state.categoria?.id;
    final subCategoriaId = state.subCategoria?.id;
    final idGerado = _generateId(categoriaId, subCategoriaId);
    emit(state.copyWith(referenciaId: idGerado, mensagem: null));
  }

  FutureOr<void> _onGerarNome(
    ReferenciaCadastroGerarNome event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    final categoria = state.categoria;
    final subCategoria = state.subCategoria;

    if (categoria == null) {
      emit(state.copyWith(mensagem: 'Selecione uma categoria'));
      return;
    }

    final nomeGerado = _generateNome(categoria, subCategoria);
    emit(state.copyWith(nome: nomeGerado, mensagem: null));
  }

  FutureOr<void> _onNomeAlterado(
    ReferenciaCadastroNomeAlterado event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    emit(state.copyWith(nome: event.nome, mensagem: null));
  }

  FutureOr<void> _onProximo(
    ReferenciaCadastroProximo event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    switch (state.step) {
      case ReferenciaCadastroStep.categoria:
        if (state.categoria == null) {
          emit(state.copyWith(mensagem: 'Selecione uma categoria'));
          return;
        }
        if (state.subCategorias.isEmpty) {
          emit(state.copyWith(step: ReferenciaCadastroStep.id));
        } else {
          emit(state.copyWith(step: ReferenciaCadastroStep.subCategoria));
        }
        return;
      case ReferenciaCadastroStep.subCategoria:
        if (state.subCategoria == null) {
          emit(state.copyWith(mensagem: 'Selecione uma sub-categoria'));
          return;
        }
        emit(state.copyWith(step: ReferenciaCadastroStep.id));
        return;
      case ReferenciaCadastroStep.id:
        if (state.referenciaId == null) {
          emit(state.copyWith(mensagem: 'Informe um ID valido'));
          return;
        }
        emit(state.copyWith(step: ReferenciaCadastroStep.nome));
        return;
      case ReferenciaCadastroStep.nome:
        if (state.nome == null || state.nome!.trim().isEmpty) {
          emit(state.copyWith(mensagem: 'Informe o nome da referencia'));
          return;
        }
        emit(state.copyWith(step: ReferenciaCadastroStep.resumo));
        return;
      case ReferenciaCadastroStep.resumo:
        return;
    }
  }

  FutureOr<void> _onVoltar(
    ReferenciaCadastroVoltar event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    switch (state.step) {
      case ReferenciaCadastroStep.categoria:
        return;
      case ReferenciaCadastroStep.subCategoria:
        emit(state.copyWith(step: ReferenciaCadastroStep.categoria));
        return;
      case ReferenciaCadastroStep.id:
        emit(
          state.copyWith(
            step: state.subCategorias.isEmpty
                ? ReferenciaCadastroStep.categoria
                : ReferenciaCadastroStep.subCategoria,
          ),
        );
        return;
      case ReferenciaCadastroStep.nome:
        emit(state.copyWith(step: ReferenciaCadastroStep.id));
        return;
      case ReferenciaCadastroStep.resumo:
        emit(state.copyWith(step: ReferenciaCadastroStep.nome));
        return;
    }
  }

  FutureOr<void> _onReiniciar(
    ReferenciaCadastroReiniciar event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    emit(
      state.copyWith(
        step: ReferenciaCadastroStep.categoria,
        categoria: null,
        subCategoria: null,
        subCategorias: const [],
        referenciaId: null,
        nome: null,
        mensagem: null,
      ),
    );
  }

  int _generateId(int? categoriaId, int? subCategoriaId) {
    final base = (categoriaId ?? 0) * 100000000;
    final sub = (subCategoriaId ?? 0) * 100000;
    final suffix = DateTime.now().millisecondsSinceEpoch % 100000;
    return base + sub + suffix;
  }

  String _generateNome(Categoria categoria, SubCategoria? subCategoria) {
    final categoriaNome = categoria.nome.toUpperCase();
    final subCategoriaNome = subCategoria?.nome ?? '';
    final nomeHumano = _generateRandomFemaleName().toUpperCase();

    if (subCategoriaNome.isEmpty) {
      return '$categoriaNome $nomeHumano';
    }

    final subCategoriaUpper = subCategoriaNome.toUpperCase();
    return '$categoriaNome $nomeHumano - $subCategoriaUpper';
  }

  String _generateRandomFemaleName() {
    const nomesFemininos = [
      'Abigail',
      'Acácia',
      'Adalgisa',
      'Adelia',
      'Ágata',
      'Alice',
      'Aline',
      'Amanda',
      'Ana',
      'Ariana',
      'Aurora',
      'Bárbara',
      'Beatriz',
      'Bianca',
      'Branca',
      'Brenda',
      'Camila',
      'Capitu',
      'Carina',
      'Carla',
      'Carmela',
      'Carolina',
      'Cássia',
      'Catarina',
      'Cecília',
      'Charlotte',
      'Cinthia',
      'Clara',
      'Cléo',
      'Cora',
      'Dafne',
      'Dalila',
      'Dalva',
      'Daniela',
      'Débora',
      'Denise',
      'Diana',
      'Dora',
      'Dóris',
      'Dulce',
      'Eleonora',
      'Elisa',
      'Elza',
      'Emanuele',
      'Emanuela',
      'Emília',
      'Érica',
      'Esmeralda',
      'Ester',
      'Eva',
      'Fábia',
      'Fabiana',
      'Fátima',
      'Fernanda',
      'Flávia',
      'Flora',
      'Gabriela',
      'Giovanna',
      'Gisela',
      'Giulia',
      'Giuliana',
      'Glória',
      'Graziela',
      'Guilhermina',
      'Haidê',
      'Hanna',
      'Hélen',
      'Helena',
      'Heloísa',
      'Hermione',
      'Iara',
      'Ingrid',
      'Iolanda',
      'Íris',
      'Isadora',
      'Ivete',
      'Ivone',
      'Iza',
      'Izabel',
      'Jade',
      'Jana',
      'Jaqueline',
      'Jasmin',
      'Jennifer',
      'Jéssica',
      'Júlia',
      'Juliana',
      'Julieta',
      'Karen',
      'Kelly',
      'Laila',
      'Laís',
      'Lana',
      'Larissa',
      'Laura',
      'Lavínia',
      'Leila',
      'Lena',
      'Letícia',
      'Liana',
      'Lídia',
      'Lígia',
      'Linda',
      'Lorena',
      'Lúcia',
      'Luciana',
      'Ludmila',
      'Luísa',
      'Madalena',
      'Maia',
      'Maísa',
      'Márcia',
      'Margarida',
      'Maria',
      'Mariana',
      'Marieta',
      'Marina',
      'Melinda',
      'Melissa',
      'Milena',
      'Mirella',
      'Miriam',
      'Mônica',
      'Nair',
      'Naomi',
      'Nara',
      'Natacha',
      'Natália',
      'Nicole',
      'Nina',
      'Olga',
      'Olívia',
      'Pamela',
      'Pandora',
      'Paola',
      'Patrícia',
      'Paula',
      'Penélope',
      'Priscila',
      'Rachel',
      'Rafaela',
      'Raissa',
      'Rebeca',
      'Regina',
      'Renata',
      'Rita',
      'Roberta',
      'Rosa',
      'Rosana',
      'Rute',
      'Sabina',
      'Sabrina',
      'Samanta',
      'Samara',
      'Sara',
      'Selena',
      'Silvana',
      'Sílvia',
      'Sônia',
      'Soraia',
      'Stela',
      'Susana',
      'Taís',
      'Tatiana',
      'Telma',
      'Teresa',
      'Valentina',
      'Vanessa',
      'Victoria',
      'Violeta',
      'Virgínia',
      'Vitória',
      'Vivian',
      'Viviana',
      'Xuxa',
      'Yasmim',
      'Yolanda',
      'Zaida',
      'Zaide',
      'Zara',
      'Zuleica',
      'Zulmira',
    ];

    final randomIndex = Random().nextInt(nomesFemininos.length);
    return nomesFemininos[randomIndex];
  }
}
