import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

/// Painel inicial. A navegação principal do app vive no menu lateral fixo
/// (ver `AppShell`) -- esta tela só mostra um resumo do dia.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<SyncDataBloc>().add(
        const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.home),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      bloc: sl<AppBloc>(),
      builder: (context, state) {
        final userName = state.usuarioDaSessao?.nome ?? 'Usuário';
        final empresaNome =
            state.empresaDaSessao?.nome ?? 'Nenhuma empresa selecionada';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeroCard(context, userName: userName, empresaNome: empresaNome),
            if (state.caixaIdDaSessao == null) ...[
              const SizedBox(height: 12),
              _buildAbrirCaixaBanner(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAbrirCaixaBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.point_of_sale_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum caixa aberto neste terminal',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Abra o caixa para iniciar vendas e recebimentos.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/fluxo_de_caixa'),
            child: const Text('Abrir caixa'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String userName,
    required String empresaNome,
  }) {
    final userInitial = userName.isNotEmpty ? userName[0] : 'U';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade500, Colors.blue.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              userInitial.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  empresaNome,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
