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
    String observacao = exame['observacao'] ?? ''; // Pega a observação
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Aumentei um pouco o padding vertical
      decoration: BoxDecoration(
        color: concluido ? const Color(0xFFE8F5E9) : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: concluido ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha itens ao topo
        children: [
          // Checkbox customizado
          GestureDetector(
            onTap: onToggle,
            child: Container(
              margin: const EdgeInsets.only(top: 2), // Pequeno ajuste visual
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: concluido ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: concluido ? Colors.green : Colors.grey.withOpacity(0.5),
                  width: 2
                ),
              ),
              child: concluido 
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Conteúdo de Texto
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do Exame
                  Text(
                    nome, 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: concluido ? Colors.grey : Colors.black87,
                      decoration: concluido ? TextDecoration.lineThrough : TextDecoration.none
                    )
                  ),
                  
                  // Observação (Só mostra se tiver texto)
                  if (observacao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      observacao,
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Recorrência (opcional, se quiser manter)
                  if (exame['recorrencia'] != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        exame['recorrencia'],
                        style: TextStyle(fontSize: 10, color: Colors.blue[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
          
          // Botão Remover
          IconButton(
            onPressed: onRemove, 
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            tooltip: "Remover exame",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), // Remove padding extra do botão
          ),
        ],
      ),
    );
  }
}