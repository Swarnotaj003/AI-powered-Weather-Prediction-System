import 'dart:math';

// fetch the max data
double getMaxPoint(List<double> dataList) {
  double maxData = double.negativeInfinity;
  for (double data in dataList) {
    maxData = max(data, maxData);
  }
  return maxData;
}

// fetch the min data
double getMinPoint(List<double> dataList) {
  double minData = double.infinity;
  for (double data in dataList) {
    minData = min(data, minData);
  }
  return minData;
}