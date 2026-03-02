double? parseAmount(String input) {
  final normalized = input.replaceAll(',', '.');
  final value = double.tryParse(normalized);
  if (value == null || value <= 0) return null;
  return value;
}
