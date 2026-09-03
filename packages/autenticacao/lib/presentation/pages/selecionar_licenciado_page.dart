import 'package:autenticacao/domain/models/licenciado.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Primeira etapa do fluxo de acesso: escolha do licenciado (multi-tenant
/// acima da empresa). O terminal memoriza a última licença usada (ver
/// `LoginBloc._onLoginCarregouLicenciados`) -- essa tela só reaparece via
/// "Trocar licenciado" no login.
class SelecionarLicenciadoPage extends StatefulWidget {
  final List<Licenciado> licenciados;

  const SelecionarLicenciadoPage({super.key, required this.licenciados});

  @override
  State<SelecionarLicenciadoPage> createState() =>
      _SelecionarLicenciadoPageState();
}

class _SelecionarLicenciadoPageState extends State<SelecionarLicenciadoPage> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final filtrados = _filtrar(widget.licenciados);

    return Scaffold(
      backgroundColor: cores.papel,
      appBar: AppBar(title: const Text('Selecionar licenciado')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Etapa 1 de 3 · Licenciado', style: textos.apoio.copyWith(color: cores.textoApoio)),
              const SizedBox(height: 4),
              Text('Escolha o licenciado para continuar', style: textos.titulo),
              const SizedBox(height: 16),
              TextField(
                key: const Key('selecionar_licenciado_busca_input'),
                controller: _buscaController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nome',
                  prefixIcon: Icon(Icons.search),
                  // TODO: busca por CNPJ não é possível hoje -- o modelo
                  // Licenciado (packages/autenticacao/lib/domain/models/licenciado.dart)
                  // só tem id/nome/urlApi, sem CNPJ.
                ),
                onChanged: (value) => setState(() => _busca = value.trim()),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtrados.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum licenciado encontrado.',
                          style: textos.corpo.copyWith(color: cores.textoApoio),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _licenciadoCard(context, filtrados[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _licenciadoCard(BuildContext context, Licenciado licenciado) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return SivCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        key: Key('selecionar_licenciado_item_${licenciado.id}'),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: () => Navigator.of(context).pop(licenciado),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.apartment_outlined, color: cores.aco),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(licenciado.nome, style: textos.corpo),
                    // TODO: CNPJ, número de empresas e último acesso não
                    // existem no modelo Licenciado hoje -- adicionar quando
                    // o backend expuser esses campos.
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cores.textoApoio),
            ],
          ),
        ),
      ),
    );
  }

  List<Licenciado> _filtrar(List<Licenciado> licenciados) {
    final termo = _busca.toLowerCase();
    if (termo.isEmpty) return licenciados;
    return licenciados
        .where((licenciado) => licenciado.nome.toLowerCase().contains(termo))
        .toList();
  }
}
