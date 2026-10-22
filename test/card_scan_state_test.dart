import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/saved_cards/data/card_scan_state.dart';
import 'package:goal_master/features/saved_cards/data/card_text_parser.dart';
import 'package:goal_master/features/saved_cards/data/card_vault.dart';

void main() {
  const cardNumber = '4111111111111111';

  test('parses four card-number groups from one OCR row', () {
    final card = parseCardText(
      ['4111 1111 1111 1111', 'TEST HOLDER', '12/30'],
      now: DateTime(2026),
    );
    expect(card.number, cardNumber);
    expect(card.holder, 'TEST HOLDER');
    expect(card.expiryText, '12/30');
  });

  test('does not fabricate a number from separate OCR rows', () {
    final card = parseCardText(['4111', '1111', '1111', '1111']);
    expect(card.number, isNull);
  });

  test('accepts only the same valid PAN over multiple frames', () {
    final state = CardScanState();
    const first = ScannedCard(
        number: cardNumber,
        holder: 'TEST HOLDER',
        expiryMonth: 12,
        expiryYear: 2030);
    const different = ScannedCard(
        number: '4012888888881881',
        holder: 'TEST HOLDER',
        expiryMonth: 12,
        expiryYear: 2030);
    expect(state.observe(first), isNull);
    expect(state.observe(different), isNull);
    expect(state.observe(first), isNull);
    final accepted = state.observe(first);
    expect(accepted?.number, cardNumber);
    expect(accepted?.holder, 'TEST HOLDER');
  });

  test('keeps saved cards isolated by authenticated owner scope', () async {
    final store = MemorySecretStore();
    final customer = CardVault(store: store, ownerId: 'customer:12');
    final manager = CardVault(store: store, ownerId: 'manager:12');
    await customer.add(
        holderName: 'Customer',
        number: cardNumber,
        expMonth: 12,
        expYear: 2030);
    expect(await customer.load(), hasLength(1));
    expect(await manager.load(), isEmpty);
  });
}
