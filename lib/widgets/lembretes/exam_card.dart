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
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: concluido ? const Color(0xFFE8F5E9) : Colors.white, // Fundo verde claro se concluído
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: concluido ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row(
        children: [
          // Checkbox customizado e maior para facilitar o toque
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: concluido ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: concluido ? Colors.green : Colors.grey,
                  width: 2
                ),
              ),
              child: concluido 
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
            ),
          ),
          const SizedBox(width: 12),
          // Área de texto clicável para editar
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome, 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: concluido ? Colors.grey : Colors.black87,
                      decoration: concluido ? TextDecoration.lineThrough : TextDecoration.none
                    )
                  ),
                  if (exame['recorrencia'] != null)
                    Text(
                      exame['recorrencia'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ),
          // Botão de remover com cor de destaque
          IconButton(
            onPressed: onRemove, 
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: "Remover exame",
          ),
        ],
      ),
    );
  }
}