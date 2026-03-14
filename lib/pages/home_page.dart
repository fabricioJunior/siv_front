import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/bloc/app_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Seção de Usuário
              BlocBuilder<AppBloc, AppState>(
                bloc: sl<AppBloc>(),
                builder: (context, state) {
                  final userName = state.usuarioDaSessao?.nome ?? 'Usuário';
                  final userInitial = userName.isNotEmpty ? userName[0] : 'U';
                  final empresaNome = state.empresaDaSessao?.nome;

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            userInitial.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bem-vindo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (empresaNome != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Empresa: $empresaNome',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Grid de Módulos
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Módulos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            if (PermissaoPorNome.acessoPermitido('ADMFM001'))
                              PermissaoPorNome(
                                idComponente: 'ADMFM001',
                                child: _ModuleCard(
                                  icon: Icons.person,
                                  title: 'Usuários',
                                  color: Colors.blue,
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/usuarios');
                                  },
                                ),
                              ),
                            if (PermissaoPorNome.acessoPermitido('ADMFM001'))
                              _ModuleCard(
                                icon: Icons.lock,
                                title: 'Grupos de Acesso',
                                color: Colors.orange,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/grupos_de_acesso');
                                },
                              ),
                            if (PermissaoPorNome.acessoPermitido('ADMFM004'))
                              _ModuleCard(
                                icon: Icons.business,
                                title: 'Empresas',
                                color: Colors.green,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/empresas');
                                },
                              ),
                            if (PermissaoPorNome.acessoPermitido('PESFM001'))
                              _ModuleCard(
                                icon: Icons.people,
                                title: 'Pessoas',
                                color: Colors.pink,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/pessoas');
                                },
                              ),
                            if (PermissaoPorNome.acessoPermitido('PRODFM001'))
                              _ModuleCard(
                                icon: Icons.shopping_bag,
                                title: 'Produtos',
                                color: Colors.purple,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/menu_produtos');
                                },
                              ),
                            if (PermissaoPorNome.acessoPermitido('SYSFM001'))
                              _ModuleCard(
                                icon: Icons.settings,
                                title: 'Configurações',
                                color: Colors.teal,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/configuracao_smtp');
                                },
                              ),
                            _ModuleCard(
                              icon: Icons.payment,
                              title: 'Pagamentos',
                              color: Colors.teal,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/pagamentos_avulsos');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Botão Sair
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('sair_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      sl<AppBloc>().add(AppDesautenticou());
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sair',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: _isHovered ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withOpacity(0.8),
                    widget.color.withOpacity(0.6),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
