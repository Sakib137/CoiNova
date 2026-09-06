import 'package:flutter/material.dart';

enum AssetCategory {
  all,
  layer1,
  defi,
  ai,
  meme,
}

class CryptoAsset {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double change24h;
  final List<double> sparkline;
  final double marketCap;
  final double volume24h;
  final double high24h;
  final double low24h;
  final double userHolding; // Amount owned in tokens
  final AssetCategory category;
  final Color brandColor;
  final IconData? iconData;

  const CryptoAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.change24h,
    required this.sparkline,
    required this.marketCap,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    this.userHolding = 0.0,
    required this.category,
    required this.brandColor,
    this.iconData,
  });

  double get holdingFiatValue => userHolding * currentPrice;

  bool get isPositive => change24h >= 0;

  String get change24hFormatted => '${isPositive ? '+' : ''}${change24h.toStringAsFixed(2)}%';

  CryptoAsset copyWithPrice({
    required double newPrice,
    required double newChange,
    required List<double> newSparkline,
  }) {
    return CryptoAsset(
      id: id,
      name: name,
      symbol: symbol,
      currentPrice: newPrice,
      change24h: newChange,
      sparkline: newSparkline,
      marketCap: marketCap,
      volume24h: volume24h,
      high24h: high24h,
      low24h: low24h,
      userHolding: userHolding,
      category: category,
      brandColor: brandColor,
      iconData: iconData,
    );
  }
}
