import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:flutter/material.dart';

class PermissaoPorNome extends StatefulWidget {
  final String idComponente;
  final Widget child;
  final Widget? fallback;

  const PermissaoPorNome({
    super.key,
    required this.idComponente,
    required this.child,
    this.fallback,
  });

  @override
  State<PermissaoPorNome> createState() => _PermissaoPorNomeState();

  static bool acessoPermitido(String idComponente) {
    return sl<IPermissoesController>().temAcesso(idComponente: idComponente);
  }
}

class _PermissaoPorNomeState extends State<PermissaoPorNome> {
  bool temAcesso = false;
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final permitido = await sl<IPermissoesController>().acessoPermitido(
        idComponente: widget.idComponente,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
        temAcesso = permitido;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const SizedBox.shrink();
    }

    if (temAcesso) {
      return widget.child;
    }

    return widget.fallback ?? const SizedBox.shrink();
  }
}

class ComponenteControladoWiget extends StatefulWidget {
  final String? idComponente;
  final int? grupoId;
  final Widget child;

  const ComponenteControladoWiget({
    super.key,
    this.idComponente,
    this.grupoId,
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
        idComponente: widget.idComponente,
        grupoId: widget.grupoId,
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
      return const SizedBox.shrink();
    }
    if (temAcesso) {
      return widget.child;
    }
    return const SizedBox();
  }
}
