import 'package:comercial/domain/use_cases/get_compras_do_cliente.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';

// Cache em memória por pessoaId -- evita rebater no RELFC010 a cada rebuild
// do seletor (ex: digitação, troca de estado do bloc). Vive só durante a
// sessão do app; ponytail: cache simples e global, trocar por algo com TTL
// se a lista de clientes distintos numa sessão crescer muito.
final Map<int, Future<String?>> _cacheUltimaCompra = {};

class UltimaCompraClienteInfo extends StatelessWidget {
  final Pessoa pessoa;

  const UltimaCompraClienteInfo({super.key, required this.pessoa});

  @override
  Widget build(BuildContext context) {
    final pessoaId = pessoa.id;
    if (pessoaId == null) return const SizedBox.shrink();

    final future = _cacheUltimaCompra.putIfAbsent(
      pessoaId,
      () => _buscarUltimaCompra(pessoaId),
    );

    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        final texto = snapshot.data == null
            ? 'Nenhuma compra anterior.'
            : 'Última compra em ${snapshot.data}.';

        return Text(
          texto,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        );
      },
    );
  }

  static Future<String?> _buscarUltimaCompra(int pessoaId) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return null;

    try {
      final dados = await sl<GetComprasDoCliente>().call(
        empresaIds: [empresaId],
        pessoaId: pessoaId,
        limit: 1,
      );
      if (dados.items.isEmpty) return null;
      final item = dados.items.first;

      final partes = item.data.split('-');
      if (partes.length != 3) return item.data;
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    } catch (_) {
      return null;
    }
  }
}
