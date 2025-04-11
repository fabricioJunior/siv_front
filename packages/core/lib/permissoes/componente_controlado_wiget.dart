import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:flutter/material.dart';

class ComponenteControladoWiget extends StatefulWidget {
  final String? nome;
  final int? id;
  final String? grupo;
  final Widget child;

  const ComponenteControladoWiget({
    super.key,
    this.grupo,
    this.id,
    this.nome,
    required this.child,
  });

  @override
  State<ComponenteControladoWiget> createState() =>
      _ComponenteControladoWigetState();
}

class _ComponenteControladoWigetState extends State<ComponenteControladoWiget> {
  bool temAcesso = false;
  bool carregando = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<IPermissoesController>()
          .acessoPermitido(
        nomeDoComponente: widget.nome,
        idComponente: widget.id,
        grupo: widget.grupo,
      )
          .then(
        (value) {
          if (mounted) {
            setState(() {
              carregando = false;
              temAcesso = value;
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const CircularProgressIndicator.adaptive();
    }
    if (temAcesso) {
      return widget.child;
    }
    return const SizedBox();
  }
}
