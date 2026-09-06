import 'dart:math';
import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../models/transaction_model.dart';

class MockCryptoData {
  static const String walletAddress = '0x4F3C89DE218A9B10';
  static const String shortAddress = '0x4F3C...9B10';
  static const String ensName = 'alex.eth';

  static List<CryptoAsset> getAssets() {
    return [
      const CryptoAsset(
        id: 'btc',
        name: 'Bitcoin',
        symbol: 'BTC',
        currentPrice: 96450.00,
        change24h: 3.42,
        sparkline: [93200, 93800, 94100, 93900, 94600, 95200, 95000, 96450],
        marketCap: 1910000000000,
        volume24h: 42800000000,
        high24h: 97100.00,
        low24h: 92800.00,
        userHolding: 0.72, // ~$69,444
        category: AssetCategory.layer1,
        brandColor: Color(0xFFF7931A),
        iconData: Icons.currency_bitcoin,
      ),
      const CryptoAsset(
        id: 'eth',
        name: 'Ethereum',
        symbol: 'ETH',
        currentPrice: 3482.50,
        change24h: 5.18,
        sparkline: [3290, 3310, 3340, 3300, 3380, 3420, 3410, 3482.5],
        marketCap: 418000000000,
        volume24h: 21500000000,
        high24h: 3520.00,
        low24h: 3280.00,
        userHolding: 12.8, // ~$44,576
        category: AssetCategory.layer1,
        brandColor: Color(0xFF627EEA),
        iconData: Icons.diamond_outlined,
      ),
      const CryptoAsset(
        id: 'sol',
        name: 'Solana',
        symbol: 'SOL',
        currentPrice: 218.40,
        change24h: 8.75,
        sparkline: [198, 202, 205, 201, 209, 214, 212, 218.4],
        marketCap: 104000000000,
        volume24h: 7800000000,
        high24h: 224.00,
        low24h: 196.50,
        userHolding: 85.0, // ~$18,564
        category: AssetCategory.layer1,
        brandColor: Color(0xFF14F195),
        iconData: Icons.flash_on,
      ),
      const CryptoAsset(
        id: 'bnb',
        name: 'BNB Chain',
        symbol: 'BNB',
        currentPrice: 652.80,
        change24h: -1.24,
        sparkline: [665, 662, 658, 661, 659, 655, 654, 652.8],
        marketCap: 95000000000,
        volume24h: 1600000000,
        high24h: 668.00,
        low24h: 648.00,
        userHolding: 12.0, // ~$7,833
        category: AssetCategory.layer1,
        brandColor: Color(0xFFF0B90B),
        iconData: Icons.shield_outlined,
      ),
      const CryptoAsset(
        id: 'render',
        name: 'Render Network',
        symbol: 'RENDER',
        currentPrice: 7.85,
        change24h: 14.62,
        sparkline: [6.8, 6.9, 7.1, 7.0, 7.3, 7.5, 7.4, 7.85],
        marketCap: 4100000000,
        volume24h: 620000000,
        high24h: 8.10,
        low24h: 6.75,
        userHolding: 850.0, // ~$6,672
        category: AssetCategory.ai,
        brandColor: Color(0xFFFF3366),
        iconData: Icons.memory,
      ),
      const CryptoAsset(
        id: 'sui',
        name: 'Sui Network',
        symbol: 'SUI',
        currentPrice: 3.45,
        change24h: 6.84,
        sparkline: [3.18, 3.22, 3.25, 3.20, 3.32, 3.39, 3.38, 3.45],
        marketCap: 9800000000,
        volume24h: 1200000000,
        high24h: 3.55,
        low24h: 3.12,
        userHolding: 1450.0, // ~$5,002
        category: AssetCategory.layer1,
        brandColor: Color(0xFF4DA2FF),
        iconData: Icons.water_drop_outlined,
      ),
      const CryptoAsset(
        id: 'link',
        name: 'Chainlink',
        symbol: 'LINK',
        currentPrice: 18.60,
        change24h: 2.15,
        sparkline: [18.1, 18.2, 18.4, 18.2, 18.3, 18.5, 18.4, 18.6],
        marketCap: 11200000000,
        volume24h: 490000000,
        high24h: 19.10,
        low24h: 17.90,
        userHolding: 150.0, // ~$2,790
        category: AssetCategory.defi,
        brandColor: Color(0xFF375BD2),
        iconData: Icons.link,
      ),
      const CryptoAsset(
        id: 'avax',
        name: 'Avalanche',
        symbol: 'AVAX',
        currentPrice: 39.54,
        change24h: 4.11,
        sparkline: [37.8, 38.1, 38.4, 38.0, 38.9, 39.2, 39.1, 39.54],
        marketCap: 16100000000,
        volume24h: 580000000,
        high24h: 40.50,
        low24h: 37.40,
        userHolding: 0.0,
        category: AssetCategory.layer1,
        brandColor: Color(0xFFE84142),
        iconData: Icons.ac_unit,
      ),
      const CryptoAsset(
        id: 'arb',
        name: 'Arbitrum',
        symbol: 'ARB',
        currentPrice: 1.22,
        change24h: -1.48,
        sparkline: [1.25, 1.24, 1.23, 1.25, 1.24, 1.21, 1.22, 1.22],
        marketCap: 4800000000,
        volume24h: 310000000,
        high24h: 1.28,
        low24h: 1.19,
        userHolding: 0.0,
        category: AssetCategory.defi,
        brandColor: Color(0xFF28A0F0),
        iconData: Icons.layers_outlined,
      ),
    ];
  }

  static double getTotalPortfolioBalance(List<CryptoAsset> assets) {
    double total = 0.0;
    for (final a in assets) {
      total += a.holdingFiatValue;
    }
    return total;
  }

  static List<TransactionModel> getTransactions() {
    return [
      TransactionModel(
        id: 'tx_1',
        type: TransactionType.swap,
        assetSymbol: 'ETH ➔ SOL',
        amount: 1.5,
        fiatAmount: 5220.0,
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        recipientOrSender: 'Uniswap v3',
        status: TransactionStatus.completed,
        txHash: '0x8f2a...19e4',
      ),
      TransactionModel(
        id: 'tx_2',
        type: TransactionType.receive,
        assetSymbol: 'BTC',
        amount: 0.15,
        fiatAmount: 14467.5,
        timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 12)),
        recipientOrSender: '0x94B1...77A2',
        status: TransactionStatus.completed,
        txHash: '0x3c71...98bb',
      ),
      TransactionModel(
        id: 'tx_3',
        type: TransactionType.send,
        assetSymbol: 'SOL',
        amount: 25.0,
        fiatAmount: 5460.0,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        recipientOrSender: '0x12FA...44E0',
        status: TransactionStatus.completed,
        txHash: '0x7e22...890a',
      ),
      TransactionModel(
        id: 'tx_4',
        type: TransactionType.stake,
        assetSymbol: 'ETH',
        amount: 4.0,
        fiatAmount: 13930.0,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        recipientOrSender: 'Lido Staking',
        status: TransactionStatus.completed,
        txHash: '0x5b33...2110',
      ),
    ];
  }

  static List<double> generateTimeframePoints(double basePrice, String timeframe) {
    final Random random = Random(basePrice.toInt() + timeframe.hashCode);
    int count = 24;
    double volatility = 0.02;

    switch (timeframe) {
      case '1H':
        count = 15;
        volatility = 0.004;
        break;
      case '1D':
        count = 24;
        volatility = 0.015;
        break;
      case '1W':
        count = 35;
        volatility = 0.04;
        break;
      case '1M':
        count = 45;
        volatility = 0.08;
        break;
      case '1Y':
        count = 60;
        volatility = 0.22;
        break;
      case 'ALL':
        count = 80;
        volatility = 0.45;
        break;
    }

    final points = <double>[];
    double current = basePrice * (1.0 - volatility * 0.7);

    for (int i = 0; i < count; i++) {
      final changePercent = (random.nextDouble() - 0.47) * volatility;
      current = current * (1.0 + changePercent);
      points.add(current);
    }
    // Ensure the last point matches current price
    points[points.length - 1] = basePrice;
    return points;
  }
}
