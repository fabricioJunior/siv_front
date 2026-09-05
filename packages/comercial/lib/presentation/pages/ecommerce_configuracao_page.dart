import 'package:comercial/presentation/pages/ecommerces_page.dart';
import 'package:flutter/material.dart';

/// Rota mantida por compatibilidade (deep link/retorno) -- o formulário de
/// configuração agora vive dentro do mestre-detalhe de `/ecommerces`. Esta
/// tela só abre `/ecommerces` já com o canal selecionado.
class EcommerceConfiguracaoPage extends StatelessWidget {
  final int? empresaId;
  final int? ecommerceId;

  const EcommerceConfiguracaoPage({super.key, this.empresaId, this.ecommerceId});

  @override
  Widget build(BuildContext context) {
    return EcommercesPage(ecommerceIdInicial: ecommerceId);
  }
}
