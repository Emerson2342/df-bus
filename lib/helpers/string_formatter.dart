import 'package:intl/intl.dart';

String priceBr(double price) {
  final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');
  final priceFormatted = formatter.format(price);
  return priceFormatted;
}

String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year} ${date.hour.toString().padLeft(2, '0')}:"
      "${date.minute.toString().padLeft(2, '0')}";
}
