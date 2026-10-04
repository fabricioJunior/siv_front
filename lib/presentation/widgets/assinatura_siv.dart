import 'package:flutter/material.dart';

/// Assinatura da marca (V + SIV + VALE DO CEARÁ) para as telas de abertura.
/// A imagem já vem com o fundo azul-marinho da marca, por isso o canto arredondado.
///
/// [recortada]: versão recortada, sem folga em volta, pra usar direto sobre o
/// fundo marinho (#1D2D3D) -- a imagem some na superfície, sem raio nem clip.
class AssinaturaSiv extends StatelessWidget {
  final double largura;
  final bool recortada;

  const AssinaturaSiv({super.key, this.largura = 280, this.recortada = false});

  @override
  Widget build(BuildContext context) {
    final imagem = Image.asset(
      recortada
          ? 'assets/brand/siv_assinatura_recorte.png'
          : 'assets/brand/siv_assinatura.png',
      width: largura,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    return Semantics(
      label: 'SIV, Vale do Ceará',
      image: true,
      child: recortada
          ? imagem
          : ClipRRect(borderRadius: BorderRadius.circular(12), child: imagem),
    );
  }
}
