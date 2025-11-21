import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart'; 
import 'noticias_screen.dart';
import 'lembretes_screen.dart'; 
import 'ia_chat_screen.dart'; 
import 'saude_educacional_screen.dart'; 

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Image.asset(
          "assets/logo1.png", 
          height: 45,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); 
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            // 🟢 CORREÇÃO: Cabeçalho manual (Container) para evitar Overflow
            Container(
              width: double.infinity,
              // Padding manual para ajustar a altura sem travar
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 20), 
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ocupa o mínimo necessário
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 35,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Olá, $userName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Itens do Menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined),
                    title: const Text('Saúde Masculina'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SaudeEducacionalScreen()),
                      );
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
            SafeArea(
              top: false, 
              child: ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () {
                  authProvider.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()), 
                    (Route<dynamic> route) => false, 
                  );
                },
              ),
            ),
            const SizedBox(height: 10), 
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                'Bem-vindo, $userName 👋',
                style: const TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                ),
                textAlign: TextAlign.left,
              ),
              const Text(
                'Cuide de você hoje.',
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.grey
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              
              AnimatedFeatureCard(
                title: 'Lembretes',
                subtitle: 'Seus exames e consultas',
                icon: Icons.notifications_active_rounded,
                color: const Color(0xFF007BFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LembretesScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              AnimatedFeatureCard(
                title: 'Notícias',
                subtitle: 'Novidades em saúde',
                icon: Icons.newspaper_rounded,
                color: const Color(0xFF3B489A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoticiasScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              AnimatedFeatureCard(
                title: 'Guia de Saúde',
                subtitle: 'Dicas, hobbies e prevenção',
                icon: Icons.health_and_safety_rounded,
                color: const Color(0xFF00BFA5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SaudeEducacionalScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              AnimatedFeatureCard(
                title: 'IA Horus', 
                subtitle: 'Seu assistente inteligente',
                icon: Icons.smart_toy_rounded,
                color: const Color(0xFF651FFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IaChatScreen()), 
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

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
    this.textColor = Colors.white, 
    required this.onTap,
  });

  @override
  State<AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<AnimatedFeatureCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        widget.color.withOpacity(0.85), 
        widget.color
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.textColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.textColor.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: widget.textColor.withOpacity(0.6), size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}