import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart'; // Assumindo que Home é a tela de Login/Boas-Vindas
import 'noticias_screen.dart';
import 'lembretes_screen.dart'; 

// Importe a nova tela de IA
import 'ia_chat_screen.dart'; // <--- NOVA IMPORTAÇÃO AQUI

class SaudeHomemScreen extends StatefulWidget {
  const SaudeHomemScreen({super.key});

  @override
  State<SaudeHomemScreen> createState() => _SaudeHomemScreenState();
}

class _SaudeHomemScreenState extends State<SaudeHomemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'Usuário';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Image.asset(
          "assets/logo1.png", 
          height: 45,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); 
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 120, 
                    child: DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color(0xFF007BFF),
                      ),
                      child: Center(
                        child: Text(
                          'Olá, $userName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined),
                    title: const Text('Saúde Masculina'),
                    onTap: () {
                      
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('Notícias'),
                    onTap: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoticiasScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Lembretes'),
                    onTap: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LembretesScreen()),
                      );
                    },
                  ),
          
                  ListTile(
                    leading: const Icon(Icons.smart_toy_outlined),
                    title: const Text('IA Horus'), 
                    onTap: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const IaChatScreen()), 
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(), 
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sair'),
              onTap: () {
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()), 
                  (Route<dynamic> route) => false, 
                );
              },
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Bem-vindo ao CheckMen, $userName',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 32),
              
              AnimatedFeatureCard(
                title: 'Lembretes',
                subtitle: 'Acompanhe seus exames e consultas agendadas',
                icon: Icons.notifications,
                color: const Color(0xFF007BFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LembretesScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              
          
              AnimatedFeatureCard(
                title: 'Notícia',
                subtitle: 'Últimas novidades em saúde masculina',
                icon: Icons.article,
                color: const Color(0xFFE8F0FE), 
                textColor: Colors.black, 
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoticiasScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Card para a própria tela de Saúde Masculina (se houver conteúdo interno)
              AnimatedFeatureCard(
                title: 'Saúde Masculina',
                subtitle: 'Dicas, hobbies e hábitos saudáveis',
                icon: Icons.monitor_heart,
                color: const Color(0xFF007BFF),
                onTap: () {
                  // Se esta tela já exibe os conteúdos de saúde,
                  // você pode não querer navegar para ela mesma.
                  // Ou pode ter subseções que você navega aqui.
                  // Por enquanto, farei um print ou apenas fecho o drawer se for o caso.
                  print('Já estamos na tela de Saúde Masculina.');
                },
              ),
              const SizedBox(height: 24),
              
              // --- AQUI VAI O CARD PARA A IA ---
              AnimatedFeatureCard(
                title: 'IA Horus', // Nome da sua IA
                subtitle: 'Seu assistente inteligente de saúde',
                icon: Icons.smart_toy,
                color: const Color(0xFFE8F0FE), // Cor clara
                textColor: Colors.black, // Texto preto para card claro
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IaChatScreen()), // NAVEGA PARA IA
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para os cards animados (deve estar no mesmo arquivo ou em um separado importado)
class AnimatedFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const AnimatedFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.textColor = Colors.white, // Cor padrão do texto
    required this.onTap,
  });

  @override
  State<AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<AnimatedFeatureCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _shadowAnimation = Tween<double>(begin: 5.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap(); // Chama o onTap do widget pai
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2 + (0.3 * (1 - _controller.value))),
                    spreadRadius: 2,
                    blurRadius: _shadowAnimation.value,
                    offset: Offset(0, _shadowAnimation.value),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.textColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.textColor.withAlpha(230), // Levemente transparente
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}