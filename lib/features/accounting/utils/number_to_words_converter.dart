class NumberToWordsConverter {
  static const List<String> _units = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen'
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  static String convert(double amount, {String currency = 'BDT', String subUnit = 'Poisha'}) {
    if (amount <= 0) return 'Zero $currency Only';

    final totalInt = amount.floor();
    final fraction = ((amount - totalInt) * 100).round();

    String words = _convertChunk(totalInt);
    if (words.trim().isEmpty) {
      words = 'Zero';
    }

    String result = '$words $currency';
    if (fraction > 0) {
      final fracWords = _convertChunk(fraction);
      result += ' and $fracWords $subUnit';
    }

    return '$result Only';
  }

  static String _convertChunk(int number) {
    if (number == 0) return '';
    if (number < 20) return _units[number];
    if (number < 100) {
      final unit = number % 10;
      return _tens[number ~/ 10] + (unit > 0 ? '-${_units[unit]}' : '');
    }
    if (number < 1000) {
      final rem = number % 100;
      return '${_units[number ~/ 100]} Hundred${rem > 0 ? ' ${_convertChunk(rem)}' : ''}';
    }
    if (number < 1000000) {
      final rem = number % 1000;
      return '${_convertChunk(number ~/ 1000)} Thousand${rem > 0 ? ' ${_convertChunk(rem)}' : ''}';
    }
    if (number < 1000000000) {
      final rem = number % 1000000;
      return '${_convertChunk(number ~/ 1000000)} Million${rem > 0 ? ' ${_convertChunk(rem)}' : ''}';
    }
    final rem = number % 1000000000;
    return '${_convertChunk(number ~/ 1000000000)} Billion${rem > 0 ? ' ${_convertChunk(rem)}' : ''}';
  }
}
