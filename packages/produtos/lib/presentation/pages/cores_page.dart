import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class CoresPage extends StatelessWidget {
  final bloc = sl<CoresBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  CoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoresBloc>(
      create: (context) => bloc..add(CoresIniciou()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<CoresBloc, CoresState>(
          builder: (context, state) {
            if (state is CoresCarregarEmProgresso) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await CorModal.show(context: context);

                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<CoresBloc>().add(CoresIniciou());
                }
              },
            );
          },
        ),
        appBar: AppBar(title: const Text('Cores')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie suas cores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar cor por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(CoresIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(CoresIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<CoresBloc, CoresState>(
                  builder: (context, state) {
                    if (state is CoresCarregarEmProgresso ||
                        state is CoresDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is CoresCarregarFalha ||
                        state is CoresDesativarFalha) {
                      return _buildError();
                    }

                    if (state is CoresCarregarSucesso ||
                        state is CoresDesativarSucesso) {
                      if (state.cores.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.cores.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final cor = state.cores[index];
                          return _buildCorCard(context, cor);
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorCard(BuildContext context, Cor cor) {
    final baseColor = _colorFromName(cor.nome);
    final isInativa = cor.inativo ?? false;
    final swatchColor = isInativa ? baseColor.withOpacity(0.3) : baseColor;
    final textColor = _contrastColor(swatchColor);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: swatchColor,
          child: Text(
            cor.id?.toString() ??
                (cor.nome.isNotEmpty
                    ? cor.nome.substring(0, 1).toUpperCase()
                    : '-'),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
        onTap: () async {
          final result = await CorModal.show(context: context, idCor: cor.id);

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<CoresBloc>().add(CoresIniciou());
          }
        },
        title: Text(
          cor.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isInativa ? 'Inativa' : 'Ativa',
              style: TextStyle(color: isInativa ? Colors.grey : Colors.purple),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteConfirmation(context, cor);
          },
        ),
      ),
    );
  }

  Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color _colorFromName(String nome) {
    final normalized = nome.trim().toLowerCase();

    final rgbColor = _parseRgbColor(normalized);
    if (rgbColor != null) {
      return rgbColor;
    }

    if (normalized.startsWith('#')) {
      final hex = normalized.substring(1);
      if (hex.length == 6 || hex.length == 8) {
        final value = int.tryParse(hex, radix: 16);
        if (value != null) {
          return Color(hex.length == 6 ? (0xFF000000 | value) : value);
        }
      }
    }

    Color base;
    if (normalized.contains('vermel')) {
      base = Colors.red;
    } else if (normalized.contains('vinho') || normalized.contains('bordo')) {
      base = const Color(0xFF7B1E1E);
    } else if (normalized.contains('azul')) {
      base = Colors.blue;
    } else if (normalized.contains('marinho') || normalized.contains('navy')) {
      base = const Color(0xFF0A2A66);
    } else if (normalized.contains('verde')) {
      base = Colors.green;
    } else if (normalized.contains('oliva') || normalized.contains('olive')) {
      base = const Color(0xFF6B8E23);
    } else if (normalized.contains('musgo')) {
      base = const Color(0xFF4A6B3C);
    } else if (normalized.contains('amare')) {
      base = Colors.yellow;
    } else if (normalized.contains('mostarda')) {
      base = const Color(0xFFC49B0B);
    } else if (normalized.contains('laran')) {
      base = Colors.orange;
    } else if (normalized.contains('cobre')) {
      base = const Color(0xFFB87333);
    } else if (normalized.contains('roxo') || normalized.contains('lila')) {
      base = Colors.purple;
    } else if (normalized.contains('lavanda')) {
      base = const Color(0xFFB57EDC);
    } else if (normalized.contains('anil') || normalized.contains('indigo')) {
      base = Colors.indigo;
    } else if (normalized.contains('rosa')) {
      base = Colors.pink;
    } else if (normalized.contains('salmao') || normalized.contains('salmon')) {
      base = const Color(0xFFFA8072);
    } else if (normalized.contains('marrom') || normalized.contains('marron')) {
      base = Colors.brown;
    } else if (normalized.contains('preto') || normalized.contains('negro')) {
      base = Colors.black;
    } else if (normalized.contains('grafite')) {
      base = const Color(0xFF3A3A3A);
    } else if (normalized.contains('branco')) {
      base = Colors.white;
    } else if (normalized.contains('gelo') || normalized.contains('offwhite')) {
      base = const Color(0xFFF8F9FA);
    } else if (normalized.contains('cinza') || normalized.contains('grey')) {
      base = Colors.grey;
    } else if (normalized.contains('prata') || normalized.contains('silver')) {
      base = const Color(0xFFC0C0C0);
    } else if (normalized.contains('ouro') || normalized.contains('gold')) {
      base = const Color(0xFFFFD700);
    } else if (normalized.contains('bege') || normalized.contains('beige')) {
      base = const Color(0xFFF5F5DC);
    } else if (normalized.contains('creme')) {
      base = const Color(0xFFFFFDD0);
    } else if (normalized.contains('ciano') || normalized.contains('cyan')) {
      base = Colors.cyan;
    } else if (normalized.contains('aqua')) {
      base = const Color(0xFF00FFFF);
    } else if (normalized.contains('turques') ||
        normalized.contains('turquesa')) {
      base = Colors.teal;
    } else if (normalized.contains('magenta')) {
      base = Colors.pinkAccent;
    } else {
      base = Colors.grey;
    }

    if (normalized.contains('claro')) {
      return _shadeColor(base, 200);
    }
    if (normalized.contains('escuro')) {
      return _shadeColor(base, 800);
    }

    return _shadeColor(base, 500);
  }

  Color _shadeColor(Color base, int shade) {
    if (base is MaterialColor) {
      return base[shade] ?? base;
    }
    if (base is MaterialAccentColor) {
      return base[shade] ?? base;
    }
    return base;
  }

  Color? _parseRgbColor(String input) {
    final rgbaMatch = RegExp(
      r'^rgba?\s*\(\s*(\d{1,3})\s*[ ,]+\s*(\d{1,3})\s*[ ,]+\s*(\d{1,3})(?:\s*[ ,/]+\s*(\d*\.?\d+))?\s*\)$',
    ).firstMatch(input);

    if (rgbaMatch != null) {
      final r = _clampByte(int.tryParse(rgbaMatch.group(1) ?? '') ?? 0);
      final g = _clampByte(int.tryParse(rgbaMatch.group(2) ?? '') ?? 0);
      final b = _clampByte(int.tryParse(rgbaMatch.group(3) ?? '') ?? 0);
      final aRaw = rgbaMatch.group(4);
      final alpha = _parseAlpha(aRaw);
      return Color.fromARGB(alpha, r, g, b);
    }

    final csvMatch = RegExp(
      r'^(\d{1,3})\s*[, ]\s*(\d{1,3})\s*[, ]\s*(\d{1,3})(?:\s*[, ]\s*(\d*\.?\d+))?$',
    ).firstMatch(input);

    if (csvMatch != null) {
      final r = _clampByte(int.tryParse(csvMatch.group(1) ?? '') ?? 0);
      final g = _clampByte(int.tryParse(csvMatch.group(2) ?? '') ?? 0);
      final b = _clampByte(int.tryParse(csvMatch.group(3) ?? '') ?? 0);
      final alpha = _parseAlpha(csvMatch.group(4));
      return Color.fromARGB(alpha, r, g, b);
    }

    return null;
  }

  int _parseAlpha(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 255;
    }
    final value = double.tryParse(raw) ?? 1.0;
    if (value <= 1.0) {
      return (value * 255).round().clamp(0, 255);
    }
    return value.round().clamp(0, 255);
  }

  int _clampByte(int value) {
    if (value < 0) return 0;
    if (value > 255) return 255;
    return value;
  }

  void _showDeleteConfirmation(BuildContext context, Cor cor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar Cor'),
        content: Text('Deseja desativar a cor "${cor.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<CoresBloc>().add(CoresDesativar(id: cor.id!));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 12),
            Text(
              'Falha ao carregar cores',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette_outlined, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhuma cor cadastrada.\nToque no botao + para criar uma nova cor.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
