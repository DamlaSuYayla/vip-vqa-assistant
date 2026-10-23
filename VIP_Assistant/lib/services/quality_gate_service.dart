import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../constants.dart';
import '../models/gate_result.dart';

class QualityGateService {
  Future<GateResult> evaluate(Uint8List bytes) {
    return compute(evaluateQualityGateBytes, bytes);
  }
}

GateResult evaluateQualityGateBytes(Uint8List bytes) {
  final img.Image? decoded = img.decodeJpg(bytes);
  if (decoded == null) {
    return const GateResult.failed(flaw: GateFlaw.blur);
  }

  final img.Image resized = _resizeToLongSide(decoded);
  final img.Image grayscale = img.grayscale(resized);

  final double meanBrightness = _meanPixelValue(grayscale);
  if (meanBrightness < QualityGateConstants.darkThreshold) {
    return GateResult.failed(
      flaw: GateFlaw.dark,
      meanBrightness: meanBrightness,
    );
  }

  final double brightFraction = _brightPixelFraction(grayscale);
  if (brightFraction > QualityGateConstants.brightThreshold) {
    return GateResult.failed(
      flaw: GateFlaw.bright,
      meanBrightness: meanBrightness,
      brightFraction: brightFraction,
    );
  }

  final double blurVariance = _laplacianVariance(grayscale);
  if (blurVariance < QualityGateConstants.blurThreshold) {
    return GateResult.failed(
      flaw: GateFlaw.blur,
      blurVariance: blurVariance,
      meanBrightness: meanBrightness,
      brightFraction: brightFraction,
    );
  }

  return GateResult.passed(
    blurVariance: blurVariance,
    meanBrightness: meanBrightness,
    brightFraction: brightFraction,
  );
}

img.Image _resizeToLongSide(img.Image source) {
  if (source.width >= source.height) {
    return img.copyResize(
      source,
      width: QualityGateConstants.resizeLongSide,
    );
  }
  return img.copyResize(
    source,
    height: QualityGateConstants.resizeLongSide,
  );
}

double _laplacianVariance(img.Image image) {
  if (image.width < QualityMathConstants.minLaplacianDimension ||
      image.height < QualityMathConstants.minLaplacianDimension) {
    return QualityMathConstants.emptyMetric;
  }

  double sum = QualityMathConstants.emptyMetric;
  double sumSquares = QualityMathConstants.emptyMetric;
  int count = 0;

  for (int y = QualityMathConstants.firstInnerPixel;
      y < image.height - QualityMathConstants.firstInnerPixel;
      y++) {
    for (int x = QualityMathConstants.firstInnerPixel;
        x < image.width - QualityMathConstants.firstInnerPixel;
        x++) {
      final int center = _grayAt(image, x, y);
      final int left = _grayAt(image, x - QualityMathConstants.firstInnerPixel,
          y);
      final int right = _grayAt(
        image,
        x + QualityMathConstants.firstInnerPixel,
        y,
      );
      final int up = _grayAt(image, x, y - QualityMathConstants.firstInnerPixel);
      final int down =
          _grayAt(image, x, y + QualityMathConstants.firstInnerPixel);
      final double laplacian =
          (QualityMathConstants.laplacianCenterWeight * center -
                  left -
                  right -
                  up -
                  down)
              .toDouble();
      sum += laplacian;
      sumSquares += laplacian * laplacian;
      count++;
    }
  }

  if (count == 0) {
    return QualityMathConstants.emptyMetric;
  }

  final double mean = sum / count;
  final double variance = (sumSquares / count) - (mean * mean);
  return variance < QualityMathConstants.varianceFloor
      ? QualityMathConstants.varianceFloor
      : variance;
}

double _meanPixelValue(img.Image image) {
  double total = QualityMathConstants.emptyMetric;
  int count = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      total += _grayAt(image, x, y);
      count++;
    }
  }

  if (count == 0) {
    return QualityMathConstants.emptyMetric;
  }
  return total / count;
}

double _brightPixelFraction(img.Image image) {
  int brightPixels = 0;
  int count = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      if (_grayAt(image, x, y) >= QualityGateConstants.saturationLevel) {
        brightPixels++;
      }
      count++;
    }
  }

  if (count == 0) {
    return QualityMathConstants.emptyMetric;
  }
  return brightPixels / count;
}

int _grayAt(img.Image image, int x, int y) {
  return image.getPixel(x, y).r.toInt();
}
