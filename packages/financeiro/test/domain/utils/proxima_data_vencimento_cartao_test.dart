import 'package:financeiro/domain/utils/proxima_data_vencimento_cartao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('proximaDataVencimentoCartao sem prazo de fechamento', () {
    test('usa o mês atual quando o dia ainda não passou', () {
      final (data, pulou) = proximaDataVencimentoCartao(
        20,
        hoje: DateTime(2026, 9, 10),
      );
      expect(data, DateTime(2026, 9, 20));
      expect(pulou, false);
    });

    test('avança pro mês seguinte quando o dia já passou', () {
      final (data, pulou) = proximaDataVencimentoCartao(
        5,
        hoje: DateTime(2026, 9, 10),
      );
      expect(data, DateTime(2026, 10, 5));
      expect(pulou, false);
    });

    test('vira o ano ao avançar de dezembro pra janeiro', () {
      final (data, pulou) = proximaDataVencimentoCartao(
        1,
        hoje: DateTime(2026, 12, 10),
      );
      expect(data, DateTime(2027, 1, 1));
      expect(pulou, false);
    });

    test('clampa dia 31 em mês curto (fevereiro não bissexto)', () {
      final (data, pulou) = proximaDataVencimentoCartao(
        31,
        hoje: DateTime(2026, 2, 10),
      );
      expect(data, DateTime(2026, 2, 28));
      expect(pulou, false);
    });
  });

  group('proximaDataVencimentoCartao com prazo de fechamento', () {
    test('fatura ainda aberta: mantém o vencimento deste ciclo', () {
      // vence dia 20, fecha 7 dias antes (dia 13); hoje é dia 10, antes do fechamento
      final (data, pulou) = proximaDataVencimentoCartao(
        20,
        prazoFechamentoDias: 7,
        hoje: DateTime(2026, 9, 10),
      );
      expect(data, DateTime(2026, 9, 20));
      expect(pulou, false);
    });

    test('fatura já fechada: pagamento avança pro próximo mês', () {
      // vence dia 20, fecha 7 dias antes (dia 13); hoje é dia 15, depois do fechamento
      final (data, pulou) = proximaDataVencimentoCartao(
        20,
        prazoFechamentoDias: 7,
        hoje: DateTime(2026, 9, 15),
      );
      expect(data, DateTime(2026, 10, 20));
      expect(pulou, true);
    });

    test('fatura fecha hoje: já considera fechada', () {
      // vence dia 20, fecha 7 dias antes (dia 13); hoje é exatamente o dia do fechamento
      final (data, pulou) = proximaDataVencimentoCartao(
        20,
        prazoFechamentoDias: 7,
        hoje: DateTime(2026, 9, 13),
      );
      expect(data, DateTime(2026, 10, 20));
      expect(pulou, true);
    });

    test('fechamento cruza virada de mês', () {
      // vence dia 5, fecha 10 dias antes -> fechamento cai em 26/set; hoje 28/set já fechou
      final (data, pulou) = proximaDataVencimentoCartao(
        5,
        prazoFechamentoDias: 10,
        hoje: DateTime(2026, 9, 28),
      );
      expect(data, DateTime(2026, 11, 5));
      expect(pulou, true);
    });
  });
}
