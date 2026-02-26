import 'package:flutter/material.dart';

import 'viewmodels/calculator_view_model.dart';
import 'views/vault_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalkulator',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF20252B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CC2FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kalkulator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CalculatorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CalculatorViewModel()..load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = const Color(0xFF2B3036);
    final Color functionButtonColor = const Color(0xFF363B42);
    final Color operatorButtonColor = const Color(0xFF353A40);
    final Color equalsButtonColor = const Color(0xFF4CC2FF);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(widget.title),
            centerTitle: false,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (_viewModel.isInPreviewMode)
                        Text(
                          _viewModel.expression,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else ...[
                        if (_viewModel.expression.isNotEmpty)
                          Text(
                            _viewModel.expression,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                        Text(
                          _viewModel.display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: <Widget>[
                    _buildButtonRow(
                      context,
                      buttons: <CalculatorButton>[
                        CalculatorButton(
                          label: '%',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.percent,
                        ),
                        CalculatorButton(
                          label: 'CE',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.clearEntry,
                        ),
                        CalculatorButton(
                          label: 'C',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.clearAll,
                        ),
                        CalculatorButton(
                          label: '⌫',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.backspace,
                        ),
                      ],
                    ),
                    _buildButtonRow(
                      context,
                      buttons: <CalculatorButton>[
                        CalculatorButton(
                          label: '1/x',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.reciprocal,
                        ),
                        CalculatorButton(
                          label: 'x²',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.square,
                        ),
                        CalculatorButton(
                          label: '²√x',
                          backgroundColor: functionButtonColor,
                          onTap: _viewModel.squareRoot,
                        ),
                        CalculatorButton(
                          label: '÷',
                          backgroundColor: operatorButtonColor,
                          onTap: () => _viewModel.inputOperator('÷'),
                        ),
                      ],
                    ),
                    _buildButtonRow(
                      context,
                      buttons: <CalculatorButton>[
                        CalculatorButton(
                          label: '7',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('7'),
                        ),
                        CalculatorButton(
                          label: '8',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('8'),
                        ),
                        CalculatorButton(
                          label: '9',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('9'),
                        ),
                        CalculatorButton(
                          label: '×',
                          backgroundColor: operatorButtonColor,
                          onTap: () => _viewModel.inputOperator('×'),
                        ),
                      ],
                    ),
                    _buildButtonRow(
                      context,
                      buttons: <CalculatorButton>[
                        CalculatorButton(
                          label: '4',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('4'),
                        ),
                        CalculatorButton(
                          label: '5',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('5'),
                        ),
                        CalculatorButton(
                          label: '6',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('6'),
                        ),
                        CalculatorButton(
                          label: '-',
                          backgroundColor: operatorButtonColor,
                          onTap: () => _viewModel.inputOperator('-'),
                        ),
                      ],
                    ),
                    _buildButtonRow(
                      context,
                      buttons: <CalculatorButton>[
                        CalculatorButton(
                          label: '1',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('1'),
                        ),
                        CalculatorButton(
                          label: '2',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('2'),
                        ),
                        CalculatorButton(
                          label: '3',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('3'),
                        ),
                        CalculatorButton(
                          label: '+',
                          backgroundColor: operatorButtonColor,
                          onTap: () => _viewModel.inputOperator('+'),
                        ),
                      ],
                    ),
                    _buildButtonRow(
                      context,
                      buttons: <CalculatorButton>[
                        CalculatorButton(
                          label: '+/-',
                          backgroundColor: buttonColor,
                          onTap: _viewModel.toggleSign,
                        ),
                        CalculatorButton(
                          label: '0',
                          backgroundColor: buttonColor,
                          onTap: () => _viewModel.inputDigit('0'),
                        ),
                        CalculatorButton(
                          label: '.',
                          backgroundColor: buttonColor,
                          onTap: _viewModel.inputDecimalPoint,
                        ),
                        CalculatorButton(
                          label: '=',
                          backgroundColor: equalsButtonColor,
                          textColor: Colors.black,
                          onTap: () {
                            final bool openVault = _viewModel.equals();
                            if (openVault) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      VaultPage(
                                    calculatorViewModel: _viewModel,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtonRow(
    BuildContext context, {
    required List<CalculatorButton> buttons,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons
            .map(
              (CalculatorButton button) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: button,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF2B3036),
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.zero,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
