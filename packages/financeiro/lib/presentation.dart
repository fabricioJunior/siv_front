library presentation;

import 'package:core/presentation.dart' show SivMenuAcordeaoFilho;

export 'presentation/blocs/fluxo_de_caixa_bloc/fluxo_de_caixa_bloc.dart';
export 'presentation/blocs/forma_de_pagamento_bloc/forma_de_pagamento_bloc.dart';
export 'presentation/blocs/formas_de_pagamento_bloc/formas_de_pagamento_bloc.dart';
export 'presentation/blocs/cancelamento_romaneio_bloc/cancelamento_romaneio_bloc.dart';
export 'presentation/blocs/suprimento_bloc/suprimento_bloc.dart';
export 'presentation/blocs/suprimentos_bloc/suprimentos_bloc.dart';
export 'presentation/blocs/sangria_bloc/sangria_bloc.dart';
export 'presentation/blocs/sangrias_bloc/sangrias_bloc.dart';
export 'presentation/blocs/fechamento_de_caixa_bloc/fechamento_de_caixa_bloc.dart';
export 'presentation/pages/cancelamento_romaneio_page.dart';
export 'presentation/pages/fluxo_de_caixa_page.dart';
export 'presentation/pages/forma_de_pagamento_page.dart';
export 'presentation/pages/formas_de_pagamento_page.dart';
export 'presentation/pages/suprimentos_page.dart';
export 'presentation/pages/suprimento_page.dart';
export 'presentation/pages/sangrias_page.dart';
export 'presentation/pages/sangria_page.dart';
export 'presentation/blocs/contagem_do_caixa_bloc/contagem_do_caixa_bloc.dart';
export 'presentation/pages/contagem_do_caixa_page.dart';
export 'presentation/widgets/formas_de_pagamento_seletor.dart';
export 'presentation/blocs/recibo_fechamento_caixa_bloc/recibo_fechamento_caixa_bloc.dart';
export 'presentation/pages/recibo_fechamento_caixa_page.dart';
export 'presentation/blocs/historico_de_caixas_bloc/historico_de_caixas_bloc.dart';
export 'presentation/pages/historico_de_caixas_page.dart';
export 'presentation/pages/selecionar_caixa_page.dart';
export 'presentation/widgets/seletor_caixa.dart';
export 'presentation/blocs/categorias_despesa_bloc/categorias_despesa_bloc.dart';
export 'presentation/blocs/categoria_despesa_bloc/categoria_despesa_bloc.dart';
export 'presentation/pages/categoria_despesa_page.dart';
export 'presentation/blocs/origens_pagamento_despesa_bloc/origens_pagamento_despesa_bloc.dart';
export 'presentation/blocs/origem_pagamento_despesa_bloc/origem_pagamento_despesa_bloc.dart';
export 'presentation/pages/origem_pagamento_despesa_page.dart';
export 'presentation/blocs/lancar_despesa_bloc/lancar_despesa_bloc.dart';
export 'presentation/pages/lancar_despesa_page.dart';
export 'presentation/blocs/calendario_de_despesas_bloc/calendario_de_despesas_bloc.dart';
export 'presentation/blocs/dashboard_de_despesas_bloc/dashboard_de_despesas_bloc.dart';
export 'presentation/pages/controle_de_despesas_page.dart';

/// Filhos do acordeão "Despesas" no menu lateral (ver `AppShell` do app).
const despesasAcordeaoItens = <SivMenuAcordeaoFilho>[
  SivMenuAcordeaoFilho(
    label: 'Controle de despesas',
    rota: '/controle_despesas',
    componente: 'DESFM003',
  ),
  SivMenuAcordeaoFilho(
    label: 'Lançar despesa',
    rota: '/lancar_despesa',
    componente: 'DESFM003',
  ),
];
