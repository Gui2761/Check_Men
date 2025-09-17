import 'package:flutter/material.dart';

class ExamCard extends StatelessWidget {
  final Map<String, dynamic> exame;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ExamCard({
    super.key,
    required this.exame,
    required this.onToggle,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    bool concluido = exame['concluido'] ?? false;
    String nome = exame['nome'] ?? 'Sem nome';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Checkbox(value: concluido, onChanged: (_) => onToggle(), activeColor: const Color(0xFF1A75B4), side: const BorderSide(color: Color(0xFF1A75B4))),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Text(nome, style: TextStyle(fontSize: 16, decoration: concluido ? TextDecoration.lineThrough : TextDecoration.none)),
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close, color: Colors.black54)),
        ],
      ),
    );
  }
}