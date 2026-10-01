import 'package:core/injecoes.dart';
import 'package:importacao/models.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

/// Importação de dados é restrita ao usuário [loginDeImportacao].
bool usuarioDaSessaoPodeImportar() =>
    usuarioPodeImportar(sl<AppBloc>().state.usuarioDaSessao?.login);
