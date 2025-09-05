import 'package:flutter/material.dart';

class SaudeHomemScreen extends StatefulWidget {
  const SaudeHomemScreen({super.key});

  @override
  State<SaudeHomemScreen> createState() => _SaudeHomemScreenState();
}

class _SaudeHomemScreenState extends State<SaudeHomemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Image.asset(
                "assets/logo1.png",
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
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
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1976D2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/logo1.png",
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      'CheckMen',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
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
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem-vindo ao CheckMen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sua plataforma completa para saúde masculina e consultas agendadas.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                'Destaques',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                title: 'Saúde Masculina',
                subtitle: 'Conheça mais sobre a sua saúde e tire suas dúvidas.',
                icon: Icons.favorite_border,
                color: Colors.blue[100]!,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                title: 'Notícias',
                subtitle: 'Fique por dentro das últimas notícias sobre saúde.',
                icon: Icons.article_outlined,
                color: Colors.green[100]!,
                iconColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                title: 'Consulta Inteligente de Saúde',
                subtitle: 'Obtenha um diagnóstico rápido e preciso.',
                icon: Icons.search,
                color: Colors.purple[100]!,
                iconColor: Colors.purple,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}