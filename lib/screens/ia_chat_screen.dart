import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Para renderizar o Markdown
import 'package:google_generative_ai/google_generative_ai.dart'; // SDK do Gemini
import 'package:flutter/services.dart'
    show rootBundle; // Para carregar a chave da API


class IaChatScreen extends StatefulWidget {
  const IaChatScreen({super.key});

  @override
  State<IaChatScreen> createState() => _IaChatScreenState();
}

class _IaChatScreenState extends State<IaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  GenerativeModel? _model; // O modelo Gemini
  ChatSession? _chat; // A sessão de chat para manter o contexto

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGenerativeModel();
  }

  Future<void> _initializeGenerativeModel() async {
    try {
      final String apiKey =
          await rootBundle.loadString('assets/generative_ai_key.txt');

      _model = GenerativeModel(
  model: 'gemini-2.5-pro',
  apiKey: apiKey,
  
  systemInstruction: Content.text(
      "Você é um assistente de saúde masculina. Responda sempre em português brasileiro de forma útil, amigável e informativa sobre temas de saúde masculina. Mantenha um tom profissional mas acessível. Não se desvie do tópico de saúde masculina, a menos que seja solicitado para uma saudação ou breve interação."
  ),
);
_chat = _model!.startChat();


_addMessage(ChatMessage(text: 'Olá, $userName! Como posso auxiliar na sua saúde masculina hoje?', isUser: false));
    } catch (e) {
      print('Erro ao inicializar o modelo Gemini: $e');
      _addMessage(ChatMessage(
          text:
              "Desculpe, não consegui conectar com a IA. Por favor, tente novamente mais tarde.",
          isUser: false));
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _model == null || _chat == null) return;

    final userMessageText = _controller.text;
    _controller.clear();
    _addMessage(ChatMessage(text: userMessageText, isUser: true));

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _chat!.sendMessage(Content.text(userMessageText));
      final aiResponseText =
          response.text ?? "Desculpe, não consegui gerar uma resposta.";
      _addMessage(ChatMessage(text: aiResponseText, isUser: false));
    } catch (e) {
      print('Erro ao enviar mensagem para a IA: $e');
      _addMessage(ChatMessage(
          text: "Desculpe, houve um erro ao processar sua solicitação.",
          isUser: false));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF007BFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('CheckMen IA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Mostra as mensagens mais recentes no final
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length -
                    1 -
                    index]; // Inverte a ordem para exibir do mais antigo para o mais novo
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                color: Color(0xFF1A75B4),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Pergunte sobre saúde masculina...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (_) =>
                        _sendMessage(), // Envia ao pressionar Enter
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: const Color(0xFF007BFF),
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF1A75B4),
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: MarkdownBody(
          // Usa MarkdownBody para renderizar a resposta da IA
          data: message.text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: message.isUser ? Colors.black87 : Colors.white,
              fontSize: 16,
            ),
            h1: TextStyle(
                color: message.isUser ? Colors.black87 : Colors.white),
            h2: TextStyle(
                color: message.isUser ? Colors.black87 : Colors.white),
            strong: TextStyle(
                color: message.isUser ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.bold),
            // Adicione mais estilos conforme necessário
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
