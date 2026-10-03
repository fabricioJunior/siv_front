import 'package:flutter/material.dart';

/// Assinatura da marca (V + SIV + VALE DO CEARÁ) para as telas de abertura.
/// A imagem já vem com o fundo azul-marinho da marca, por isso o canto arredondado.
class AssinaturaSiv extends StatelessWidget {
  final double largura;

  const AssinaturaSiv({super.key, this.largura = 280});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SIV, Vale do Ceará',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/brand/siv_assinatura.png',
          width: largura,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
