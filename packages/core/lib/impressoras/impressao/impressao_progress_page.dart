import 'package:core/impressoras/impressao/impressao_progress_cubit.dart';
import 'package:core/impressoras/impressao/item_de_impressao.dart';
import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ImpressaoProgressPage extends StatelessWidget {
	const ImpressaoProgressPage({
		super.key,
		required this.itens,
		required this.quantidadeDeVias,
	});

	final List<ItemDeImpressao> itens;
	final int quantidadeDeVias;

	@override
	Widget build(BuildContext context) {
		return BlocProvider(
			create: (_) => ImpressaoProgressCubit(
				printersService: GetIt.instance<IPrintersService>(),
				itens: itens,
				quantidadeDeVias: quantidadeDeVias,
			),
			child: const _ImpressaoProgressView(),
		);
	}
}

class _ImpressaoProgressView extends StatelessWidget {
	const _ImpressaoProgressView();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Impressao de etiquetas')),
			body: BlocBuilder<ImpressaoProgressCubit, ImpressaoProgressState>(
				builder: (context, state) {
					return switch (state.status) {
						ImpressaoProgressStatus.carregandoImpressoras =>
							_buildCarregando(),
						ImpressaoProgressStatus.aguardandoConfirmacao =>
							_buildSelecao(context, state),
						ImpressaoProgressStatus.imprimindo =>
							_buildProgresso(state),
						ImpressaoProgressStatus.sucesso =>
							_buildSucesso(context),
						ImpressaoProgressStatus.erro =>
							_buildErro(context, state),
					};
				},
			),
		);
	}

	Widget _buildCarregando() {
		return const Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					CircularProgressIndicator.adaptive(),
					SizedBox(height: 16),
					Text('Carregando impressoras...'),
				],
			),
		);
	}

	Widget _buildSelecao(BuildContext context, ImpressaoProgressState state) {
		final cubit = context.read<ImpressaoProgressCubit>();

		return Column(
			children: [
				Expanded(
					child: ListView(
						padding: const EdgeInsets.all(16),
						children: [
							Card(
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											const Text(
												'Resumo',
												style: TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.w700,
												),
											),
											const SizedBox(height: 8),
											Row(
												children: [
													const Icon(Icons.label_outline, size: 18),
													const SizedBox(width: 8),
													Text('Total de etiquetas: ${state.totalEtiquetas}'),
												],
											),
										],
									),
								),
							),
							const SizedBox(height: 12),
							Card(
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											const Text(
												'Selecione a impressora',
												style: TextStyle(
													fontSize: 16,
													fontWeight: FontWeight.w700,
												),
											),
											const SizedBox(height: 8),
											if (state.impressoras.isEmpty)
												const Padding(
													padding: EdgeInsets.symmetric(vertical: 8),
													child: Text('Nenhuma impressora disponivel.'),
												)
											else
												...state.impressoras.map(
													(impressora) => RadioListTile<Impressora>(
														value: impressora,
														groupValue: state.impressoraSelecionada,
														onChanged: impressora.isAvailable
																? (v) {
																		if (v != null) {
																			cubit.selecionarImpressora(v);
																		}
																	}
																: null,
														title: Text(impressora.name),
														subtitle: Text(
															'${impressora.model} — ${impressora.location}',
														),
													),
												),
										],
									),
								),
							),
						],
					),
				),
				Padding(
					padding: const EdgeInsets.all(16),
					child: SizedBox(
						width: double.infinity,
						child: FilledButton.icon(
							onPressed: state.impressoraSelecionada == null
									? null
									: () => cubit.confirmarImpressao(),
							icon: const Icon(Icons.print),
							label: const Text('Confirmar impressao'),
						),
					),
				),
			],
		);
	}

	Widget _buildProgresso(ImpressaoProgressState state) {
		final percent = state.percentualProgresso;
		final descricao = state.descricaoAtual;

		return Center(
			child: Padding(
				padding: const EdgeInsets.all(32),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Icon(Icons.print_outlined, size: 56),
						const SizedBox(height: 24),
						Text(
							'Imprimindo ${state.progressoAtual} de ${state.totalEtiquetas}...',
							style: const TextStyle(fontSize: 16),
							textAlign: TextAlign.center,
						),
						if (descricao != null) ...[
							const SizedBox(height: 8),
							Text(
								descricao,
								style: const TextStyle(fontWeight: FontWeight.w500),
								textAlign: TextAlign.center,
							),
						],
						const SizedBox(height: 24),
						LinearProgressIndicator(value: percent),
						const SizedBox(height: 8),
						Text('${(percent * 100).toStringAsFixed(0)}%'),
					],
				),
			),
		);
	}

	Widget _buildSucesso(BuildContext context) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(32),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						const Icon(
							Icons.check_circle_outline,
							size: 72,
							color: Colors.green,
						),
						const SizedBox(height: 24),
						const Text(
							'Impressao concluida com sucesso!',
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
							textAlign: TextAlign.center,
						),
						const SizedBox(height: 32),
						FilledButton.icon(
							onPressed: () => Navigator.of(context).pop(),
							icon: const Icon(Icons.check),
							label: const Text('Fechar'),
						),
					],
				),
			),
		);
	}

	Widget _buildErro(BuildContext context, ImpressaoProgressState state) {
		final cubit = context.read<ImpressaoProgressCubit>();

		return Center(
			child: Padding(
				padding: const EdgeInsets.all(32),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.error_outline,
							size: 72,
							color: Colors.redAccent.shade700,
						),
						const SizedBox(height: 24),
						const Text(
							'Falha na impressao',
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
							textAlign: TextAlign.center,
						),
						if (state.mensagemErro != null) ...[
							const SizedBox(height: 12),
							Text(
								state.mensagemErro!,
								textAlign: TextAlign.center,
							),
						],
						const SizedBox(height: 32),
						Wrap(
							spacing: 12,
							runSpacing: 12,
							alignment: WrapAlignment.center,
							children: [
								OutlinedButton.icon(
									onPressed: () => Navigator.of(context).pop(),
									icon: const Icon(Icons.close),
									label: const Text('Fechar'),
								),
								FilledButton.icon(
									onPressed: () => cubit.carregarImpressoras(),
									icon: const Icon(Icons.refresh),
									label: const Text('Tentar novamente'),
								),
							],
						),
					],
				),
			),
		);
	}
}
