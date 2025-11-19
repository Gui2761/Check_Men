import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class IaChatScreen extends StatefulWidget {
  const IaChatScreen({super.key});

  @override
  State<IaChatScreen> createState() => _IaChatScreenState();
}

class _IaChatScreenState extends State<IaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeGenerativeModel();
      _isInitialized = true;
    }
  }

  Future<void> _initializeGenerativeModel() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userName = authProvider.userName ?? 'Amigo';
      
      // Carrega a chave de forma segura do arquivo assets
      final String apiKey = await rootBundle.loadString('assets/generative_ai_key.txt');
      final cleanApiKey = apiKey.trim(); 

      if (cleanApiKey.isEmpty) {
        throw Exception('Chave de API vazia');
      }

      _model = GenerativeModel(
        // 🟢 MUDANÇA AQUI: Trocado para 'gemini-pro' (mais estável)
        model: 'gemini-2.5-pro', 
        apiKey: cleanApiKey,
        systemInstruction: Content.text(
            "Você é o Horus, um assistente especializado em saúde masculina preventiva do app CheckMen. "
            "Responda sempre de forma educada, direta e em português do Brasil. "
            "Seu foco é: prevenção de doenças (próstata, coração, diabetes), saúde mental masculina, nutrição e exercícios. "
            "IMPORTANTE: Você NÃO substitui um médico. Sempre recomende que o usuário procure um profissional para diagnósticos. "
            "Se perguntarem sobre assuntos fora de saúde/bem-estar, diga educadamente que só pode ajudar com saúde masculina."
        ),
      );
      
      _chat = _model!.startChat();

      _addMessage(ChatMessage(
          text: 'Olá, $userName! Sou o Horus. Como posso ajudar a cuidar da sua saúde hoje?',
          isUser: false));
          
    } catch (e) {
      print('Erro ao inicializar Gemini: $e');
      _addMessage(ChatMessage(
          text: "Ops! Não consegui conectar aos meus servidores. Verifique sua internet ou a chave de API.",
          isUser: false));
    }
  }

  void _addMessage(ChatMessage message) {
    if (!mounted) return;
    setState(() {
      _messages.add(message);
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _model == null || _chat == null || _isLoading) return;

    _controller.clear();
    _addMessage(ChatMessage(text: text, isUser: true));

    setState(() => _isLoading = true);

    try {
      final response = await _chat!.sendMessage(Content.text(text));
      final aiResponseText = response.text ?? "Não entendi, pode reformular?";
      _addMessage(ChatMessage(text: aiResponseText, isUser: false));
    } catch (e) {
      // 🟢 Adicionado print do erro no console para ajudar a debugar
      print("Erro Gemini: $e"); 
      _addMessage(ChatMessage(
          text: "Desculpe, tive um erro ao processar sua resposta. Tente novamente.",
          isUser: false));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B489A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Icons.smart_toy_outlined, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Horus - IA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Horus está digitando...", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
          const SizedBox(height: 5),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Tire sua dúvida de saúde...',
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: const Color(0xFF3B489A),
            elevation: 2,
            mini: true,
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF3B489A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: isUser ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))],
        ),
        child: isUser 
          ? Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 16))
          : MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.black87, fontSize: 16),
                strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B489A)),
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