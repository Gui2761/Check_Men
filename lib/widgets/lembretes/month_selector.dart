import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final List<String> meses;
  final String mesAtual;
  final Function(int) onChangeMonth;

  const MonthSelector({
    super.key,
    required this.meses,
    required this.mesAtual,
    required this.onChangeMonth,
  });

  @override
  Widget build(BuildContext context) {
    int mesIndex = meses.indexOf(mesAtual);
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMonthButton(meses[(mesIndex - 1 + meses.length) % meses.length], isSelected: false, onTap: () => onChangeMonth((mesIndex - 1 + meses.length) % meses.length)),
          _buildMonthButton(meses[mesIndex], isSelected: true, onTap: () {}),
          _buildMonthButton(meses[(mesIndex + 1) % meses.length], isSelected: false, onTap: () => onChangeMonth((mesIndex + 1) % meses.length)),
        ],
      ),
    );
  }

  Widget _buildMonthButton(String text, {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF1A75B4) : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }
}