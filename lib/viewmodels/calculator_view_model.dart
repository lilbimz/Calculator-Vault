import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel untuk logika kalkulator.
class CalculatorViewModel extends ChangeNotifier {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  static const String _pinPrefsKey = 'vault_pin';

  /// PIN rahasia untuk membuka halaman vault.
  /// Default pertama kali adalah '1234', lalu bisa diubah dan disimpan.
  String _secretPin = '1234';

  String get display => _display;
  String get expression => _expression;
  String get secretPin => _secretPin;

  bool get isInPreviewMode =>
      _expression.isNotEmpty && !_expression.trimRight().endsWith('=');

  /// Memuat PIN dari SharedPreferences.
  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedPin = prefs.getString(_pinPrefsKey);
    if (storedPin != null && storedPin.isNotEmpty) {
      _secretPin = storedPin;
      notifyListeners();
    }
  }

  /// Mengubah PIN dan menyimpannya ke SharedPreferences.
  Future<void> updatePin(String newPin) async {
    if (newPin.isEmpty) return;
    _secretPin = newPin;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinPrefsKey, _secretPin);
    notifyListeners();
  }

  void inputDigit(String digit) {
    if (_display == 'Error') {
      _resetAll();
    }
    if (digit == '0' && _display == '0' && _firstOperand == null) {
      return;
    }

    if (_shouldResetDisplay || _display == '0') {
      _display = digit;
      if (_operator != null && _firstOperand != null) {
        _expression = '${_formatNumber(_firstOperand!)} $_operator $digit';
      } else {
        _expression = digit;
      }
      _shouldResetDisplay = false;
    } else {
      _display += digit;
      if (_operator != null && _firstOperand != null) {
        _expression = '${_formatNumber(_firstOperand!)} $_operator $_display';
      } else {
        _expression = _display;
      }
    }
    notifyListeners();
  }

  void inputDecimalPoint() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _expression = _display;
      _shouldResetDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
      _expression = _display;
    }
    notifyListeners();
  }

  void toggleSign() {
    if (_display == '0' || _display == 'Error') return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
    _expression = _display;
    notifyListeners();
  }

  void clearEntry() {
    _display = '0';
    _shouldResetDisplay = false;
    _expression = '';
    notifyListeners();
  }

  void clearAll() {
    _resetAll();
    notifyListeners();
  }

  void backspace() {
    if (_shouldResetDisplay) {
      _display = '0';
      _shouldResetDisplay = false;
      _expression = '';
      notifyListeners();
      return;
    }
    if (_display.length <= 1 ||
        (_display.length == 2 && _display.startsWith('-'))) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
    }

    if (_operator != null && _firstOperand != null && _display != '0') {
      _expression = '${_formatNumber(_firstOperand!)} $_operator $_display';
    } else if (_display == '0') {
      _expression = '';
    } else {
      _expression = _display;
    }
    notifyListeners();
  }

  void inputOperator(String op) {
    final double currentValue = double.tryParse(_display) ?? 0;

    // Simpan operand pertama saja, perhitungan di '='.
    if (_firstOperand == null || _shouldResetDisplay) {
      _firstOperand = currentValue;
    }
    _operator = op;
    _shouldResetDisplay = true;
    if (_firstOperand != null && _operator != null) {
      _expression = '${_formatNumber(_firstOperand!)} $_operator';
    }
    notifyListeners();
  }

  /// Meng-handle tombol '='.
  ///
  /// Mengembalikan `true` jika kode rahasia dimasukkan dan
  /// UI harus membuka halaman vault.
  bool equals() {
    // Deteksi kode rahasia ketika tidak ada operasi.
    if (_firstOperand == null &&
        _operator == null &&
        _display == _secretPin) {
      _resetAll();
      notifyListeners();
      return true;
    }

    if (_firstOperand == null || _operator == null) return false;
    final double secondOperand = double.tryParse(_display) ?? 0;

    final String firstText = _formatNumber(_firstOperand!);
    final String secondText = _formatNumber(secondOperand);
    final String op = _operator!;
    final double result = _computeResult(_firstOperand!, secondOperand, op);

    _display = _formatNumber(result);
    _expression = '$firstText $op $secondText =';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = true;
    notifyListeners();
    return false;
  }

  void percent() {
    final double current = double.tryParse(_display) ?? 0;
    _display = _formatNumber(current / 100);
    _shouldResetDisplay = true;
    _expression = _display;
    notifyListeners();
  }

  void reciprocal() {
    final double current = double.tryParse(_display) ?? 0;
    if (current == 0) {
      _display = 'Error';
    } else {
      _display = _formatNumber(1 / current);
    }
    _shouldResetDisplay = true;
    _expression = _display;
    notifyListeners();
  }

  void square() {
    final double current = double.tryParse(_display) ?? 0;
    _display = _formatNumber(current * current);
    _shouldResetDisplay = true;
    _expression = _display;
    notifyListeners();
  }

  void squareRoot() {
    final double current = double.tryParse(_display) ?? 0;
    if (current < 0) {
      _display = 'Error';
    } else {
      _display =
          _formatNumber(current >= 0 ? _sqrt(current) : 0);
    }
    _shouldResetDisplay = true;
    _expression = _display;
    notifyListeners();
  }

  void _resetAll() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = false;
  }

  double _computeResult(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return double.nan;
        return a / b;
      default:
        return b;
    }
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  double _sqrt(double value) => value <= 0 ? 0 : math.sqrt(value);
}

