class LedgerDataJp {
  final DateTime? date;
  final int? income;
  final int? expense;
  final int? balance;
  final String? memo;

  LedgerDataJp({this.date, this.income, this.expense, this.balance, this.memo});

  @override
  String toString() {
    return '日付: $date, 収入: $income, 支出: $expense, 残高: $balance, メモ: $memo';
  }
}

LedgerDataJp parseLedgerTextJp(String ocrText) {
  // 日付抽出 (例: 2024年5月29日)
  final dateReg = RegExp(r'(\d{4})年\s*(\d{1,2})月\s*(\d{1,2})日');
  final dateMatch = dateReg.firstMatch(ocrText);
  DateTime? date;
  if (dateMatch != null) {
    final year = int.parse(dateMatch.group(1)!);
    final month = int.parse(dateMatch.group(2)!);
    final day = int.parse(dateMatch.group(3)!);
    date = DateTime(year, month, day);
  }

  // 収入抽出
  final incomeReg = RegExp(r'収入[:：]?\s*([\d,]+)円');
  final incomeMatch = incomeReg.firstMatch(ocrText);
  int? income;
  if (incomeMatch != null) {
    income = int.parse(incomeMatch.group(1)!.replaceAll(',', ''));
  }

  // 支出抽出
  final expenseReg = RegExp(r'支出[:：]?\s*([\d,]+)円');
  final expenseMatch = expenseReg.firstMatch(ocrText);
  int? expense;
  if (expenseMatch != null) {
    expense = int.parse(expenseMatch.group(1)!.replaceAll(',', ''));
  }

  // 残高抽出
  final balanceReg = RegExp(r'残高[:：]?\s*([\d,]+)円');
  final balanceMatch = balanceReg.firstMatch(ocrText);
  int? balance;
  if (balanceMatch != null) {
    balance = int.parse(balanceMatch.group(1)!.replaceAll(',', ''));
  }

  // メモ抽出
  final memoReg = RegExp(r'メモ[:：]?\s*(.*)');
  final memoMatch = memoReg.firstMatch(ocrText);
  String? memo;
  if (memoMatch != null) {
    memo = memoMatch.group(1)?.trim();
  }

  return LedgerDataJp(
    date: date,
    income: income,
    expense: expense,
    balance: balance,
    memo: memo,
  );
}
