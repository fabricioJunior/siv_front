import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class AberturaDeCaixaPage extends StatelessWidget {
  final int? empresaId;
  final int? terminalId;
  final String? empresaNome;
  final String? terminalNome;
  final bool carregando;
  final String? erro;
  final VoidCallback onAbrir;

  const AberturaDeCaixaPage({
    super.key,
    required this.empresaId,
    required this.terminalId,
    this.empresaNome,
    this.terminalNome,
    required this.carregando,
    this.erro,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final podeAbrir = !carregando && empresaId != null && terminalId != null;

    final subtitulo = empresaId == null || terminalId == null
        ? 'Sessão sem empresa ou terminal definido. Selecione-os para abrir o caixa.'
        : [terminalNome, empresaNome].whereType<String>().join(' · ');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: cores.superficie,
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  border: Border.all(color: cores.aco),
                  boxShadow: [
                    BoxShadow(
                      color: cores.aco.withValues(alpha: 0.12),
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.point_of_sale_rounded,
                      size: 40,
                      color: cores.aco,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Abertura de caixa',
                      textAlign: TextAlign.center,
                      style: textos.secao.copyWith(fontSize: 21),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitulo,
                      textAlign: TextAlign.center,
                      style: textos.apoio.copyWith(
                        color: empresaId == null || terminalId == null
                            ? cores.atencao
                            : cores.textoApoio,
                      ),
                    ),
                    if (erro != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cores.falhaFundo,
                          border: Border.all(color: cores.falhaBorda),
                          borderRadius: BorderRadius.circular(
                            SivDimensoes.raio,
                          ),
                        ),
                        child: Text(
                          erro!,
                          textAlign: TextAlign.center,
                          style: textos.apoio.copyWith(
                            color: cores.textoPrincipal,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: podeAbrir ? onAbrir : null,
                        icon: carregando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock_open_outlined),
                        label: Text(
                          carregando ? 'ABRINDO CAIXA...' : 'ABRIR CAIXA',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...sivCantosBlueprint(cores.aco),
            ],
          ),
        ),
      ),
    );
  }
}
