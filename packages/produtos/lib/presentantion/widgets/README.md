# Widgets de seleção

## SeletorGenerico<T>

O `SeletorGenerico<T>` é um campo com chips e autocomplete em overlay.

### Quando usar

- Quando você precisa selecionar itens a partir de uma lista em memória.
- Quando quer seleção única ou múltipla com o mesmo componente.
- Quando precisa reaproveitar o mesmo comportamento entre tipos diferentes (cor, marca, categoria, etc.).

### API principal

- `itens`: lista completa de opções.
- `itemLabel`: função para exibir o texto de cada item.
- `itemKey`: identificador estável para comparação (ex.: id). Se não for informado, usa `itemLabel`.
- `modo`: `SeletorGenericoModo.unica` ou `SeletorGenericoModo.multipla`.
- `selecionadosIniciais`: itens já selecionados.
- `onChanged`: callback com a lista atual de itens selecionados.
- `titulo`: título acima do campo.
- `hintText`: dica no campo de busca.
- `maxSugestoes`: limite de sugestões no dropdown.
- `chipAvatarBuilder`: permite renderizar ícone/avatar nos chips selecionados.
- `sugestaoLeadingBuilder`: permite renderizar ícone/avatar à esquerda da sugestão.
- `sugestaoTrailingBuilder`: permite renderizar ícone/avatar à direita da sugestão.
- `confirmarEmSeparadores`: confirma automaticamente a melhor sugestão quando o texto termina com separadores (ex.: `,` e `;`).

### Exemplo (seleção múltipla)

```dart
SeletorGenerico<Cor>(
  itens: coresAtivas,
  itemLabel: (cor) => cor.nome,
  itemKey: (cor) => cor.id,
  modo: SeletorGenericoModo.multipla,
  selecionadosIniciais: coresIniciais,
  onChanged: (coresSelecionadas) {
    // salvar no estado da tela
  },
  titulo: 'Cores',
  hintText: 'Digite para buscar uma cor',
  maxSugestoes: 3,
  chipAvatarBuilder: (_, __) => const Icon(Icons.palette_outlined, size: 16),
  sugestaoLeadingBuilder: (context, __) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 14,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(
        Icons.palette,
        size: 14,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  },
  confirmarEmSeparadores: const [',', ';'],
)
```

### Exemplo (seleção única)

```dart
SeletorGenerico<Marca>(
  itens: marcas,
  itemLabel: (marca) => marca.nome,
  itemKey: (marca) => marca.id,
  modo: SeletorGenericoModo.unica,
  selecionadosIniciais: marcaAtual == null ? [] : [marcaAtual!],
  onChanged: (selecionadas) {
    final marcaSelecionada = selecionadas.isEmpty ? null : selecionadas.first;
  },
  titulo: 'Marca',
  hintText: 'Digite para buscar marca',
)
```

### Observações

- Em seleção múltipla, itens já selecionados não aparecem nas sugestões.
- Pressionar `Enter` seleciona a melhor sugestão disponível.
- Pressionar `Backspace` com campo vazio remove o último chip.
- O `overlay` é ancorado ao campo e acompanha seu tamanho.

## TamanhoSeletor

Widget pronto para uso, carregando dados com `TamanhosBloc`.

```dart
TamanhoSeletor(
  modo: TamanhoSeletorModo.multipla,
  onChanged: (tamanhosSelecionados) {
    // usar tamanhos selecionados
  },
)
```

## ReferenciaSeletor

Widget pronto para uso, carregando dados com `ReferenciasBloc`.

```dart
ReferenciaSeletor(
  modo: ReferenciaSeletorModo.unica,
  onChanged: (referenciasSelecionadas) {
    final referencia = referenciasSelecionadas.isEmpty
        ? null
        : referenciasSelecionadas.first;
  },
)
```
