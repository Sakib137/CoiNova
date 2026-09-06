import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinova/main.dart';
import 'package:coinova/data/mock_crypto_data.dart';
import 'package:coinova/widgets/slide_to_confirm.dart';
import 'package:coinova/widgets/fear_greed_meter.dart';
import 'package:coinova/widgets/dex_route_visualizer.dart';

void main() {
  testWidgets('CoinovaApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoinovaApp());

    expect(find.text('COINOVA'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('FearGreedMeter renders sentiment score and insight', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FearGreedMeter(score: 82, sentiment: 'Extreme Greed'),
        ),
      ),
    );

    expect(find.text('82'), findsOneWidget);
    expect(find.text('Extreme Greed'), findsOneWidget);
    expect(find.text('Crypto Market Sentiment Index'), findsOneWidget);
  });

  testWidgets('SlideToConfirm renders shimmer label and knob', (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: SlideToConfirm(
              label: 'Slide to Confirm Swap',
              onConfirmed: () => confirmed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Slide to Confirm Swap'), findsOneWidget);
    expect(confirmed, isFalse);
  });

  testWidgets('DexRouteVisualizer renders multi-hop route nodes and savings', (WidgetTester tester) async {
    final assets = MockCryptoData.getAssets();
    final eth = assets[0];
    final sol = assets[1];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DexRouteVisualizer(
            payAsset: eth,
            receiveAsset: sol,
          ),
        ),
      ),
    );

    expect(find.text('Smart DEX Aggregation'), findsOneWidget);
    expect(find.text('Uniswap v3'), findsOneWidget);
    expect(find.text('Curve 3Pool'), findsOneWidget);
  });
}
