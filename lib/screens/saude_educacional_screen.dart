import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SaudeEducacionalScreen extends StatelessWidget {
  const SaudeEducacionalScreen({super.key});

  final List<Map<String, dynamic>> topics = const [
    {
      'title': 'Coração Forte',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFFF5252),
      'content': '''
# ❤️ Cuide do motor do seu corpo

As doenças cardiovasculares são a principal causa de morte entre homens no Brasil.

<br>

### 🩺 Pressão Arterial
A hipertensão é silenciosa. Meça sua pressão pelo menos **uma vez ao ano**.

<br>

### 🥗 Colesterol
Evite gorduras trans e saturadas (frituras, industrializados). Prefira azeite, castanhas e peixes.

<br>

### 🏃 Exercício
**30 minutos** de caminhada diária reduzem drasticamente o risco de infarto e AVC.

<br>

### ⚠️ Sintomas de Alerta
Dor no peito, falta de ar ao esforço e palpitações exigem avaliação médica **imediata**.
      '''
    },
    {
      'title': 'Prevenção (Próstata)',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF2979FF),
      'content': '''
# 🛡️ O tabu que custa vidas

O câncer de próstata é o segundo mais comum entre os homens.

<br>

### 📅 Quando começar?
* **A partir dos 50 anos:** Para todos os homens.
* **A partir dos 45 anos:** Se seu pai ou irmão tiveram a doença ou se você é negro (fator de risco).

<br>

### 🔍 Os Exames
O exame de toque retal e o PSA (exame de sangue) são complementares e devem ser feitos **anualmente**.

<br>

### 🚨 Sintomas
Dificuldade para urinar, jato urinário fraco, levantar várias vezes à noite para urinar ou sangue na urina.

<br>

> **Diagnóstico Precoce:** Quando descoberto no início, as chances de cura ultrapassam **90%**.
      '''
    },
    {
      'title': 'Saúde Mental',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF651FFF),
      'content': '''
# 🧠 Homem também sente

Depressão, ansiedade e burnout não são frescura. A saúde mental impacta diretamente sua saúde física, libido e imunidade.

<br>

* **🗣️ Fale sobre o que sente:** Guardar sentimentos aumenta o estresse e o risco cardíaco.
* **🚩 Sinais de Alerta:** Irritabilidade excessiva, insônia constante, perda de libido, desânimo profundo e isolamento.
* **🤝 Busque Ajuda:** Terapia é fundamental. Não tenha vergonha de procurar um psicólogo.
* **🎮 Hobbies:** Tenha um tempo sagrado para você, longe do trabalho e das obrigações.
      '''
    },
    {
      'title': 'Nutrição e Peso',
      'icon': Icons.restaurant_menu_rounded,
      'color': Color(0xFF43A047),
      'content': '''
# 🥗 Você é o que você come

A obesidade central (gordura na barriga) é um grande fator de risco para diabetes e problemas cardíacos.

<br>

### 💧 Água
Beba pelo menos **2 a 3 litros** por dia. A hidratação melhora o foco, a pele e a disposição.

<br>

### 🧂 Menos Sal
O excesso de sódio eleva a pressão. Use ervas e temperos naturais para dar sabor.

<br>

### 🍎 Fibras
Coma mais frutas, verduras e integrais para evitar o câncer de intestino e regular o organismo.

<br>

### 🍺 Álcool
Se beber, faça com moderação, intercale com água e nunca dirija.
      '''
    },
    {
      'title': 'Saúde Sexual',
      'icon': Icons.male_rounded,
      'color': Color(0xFFFFAB00),
      'content': '''
# 🍆 Prevenção e desempenho

<br>

### 🛡️ ISTs
O uso de preservativo é indispensável. É a única proteção eficaz contra HIV, Sífilis, Gonorreia e outras infecções.

<br>

### ⚠️ Disfunção Erétil
Falhas eventuais são normais. Se for frequente, pode ser sinal de:
* Diabetes
* Problemas cardíacos
* Questões hormonais

**Não se automedique.** Consulte um urologista.

<br>

### 🚿 Higiene
A higiene correta da região genital previne infecções, fungos e até o câncer de pênis. Lave diariamente com água e sabão, puxando o prepúcio.
      '''
    },
    {
      'title': 'Check-up por Idade',
      'icon': Icons.calendar_month_rounded,
      'color': Color(0xFF546E7A),
      'content': '''
# 📋 O que fazer e quando?

<br>

### 🟢 20 a 29 anos
* Medição de pressão arterial
* Testes rápidos de ISTs
* Glicose e Colesterol
* Autoexame dos testículos

<br>

### 🟡 30 a 39 anos
* Todos os anteriores
* Triglicérides
* Função renal e hepática
* Exame oftalmológico

<br>

### 🟠 40 a 49 anos
* Todos os anteriores
* Avaliação cardiológica completa
* Rastreamento de próstata (a partir dos 45 se tiver risco)

<br>

### 🔴 50+ anos
* Todos os anteriores
* Colonoscopia (prevenção de câncer de intestino)
* Audiometria e Densitometria óssea
      '''
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Guia de Saúde", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF007BFF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: topics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return _buildTopicCard(context, topics[index]);
          },
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, dynamic> topic) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicDetailScreen(topic: topic),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: topic['color'].withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'icon_${topic['title']}',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: topic['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(topic['icon'], size: 36, color: topic['color']),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                topic['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicDetailScreen extends StatelessWidget {
  final Map<String, dynamic> topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = topic['color'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: mainColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                topic['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                ),
              ),
              background: Container(
                color: mainColor,
                child: Center(
                  child: Hero(
                    tag: 'icon_${topic['title']}',
                    child: Icon(topic['icon'], size: 80, color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: MarkdownBody(
                data: topic['content'],
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                    color: mainColor, 
                    fontSize: 26, 
                    fontWeight: FontWeight.w800, 
                    height: 1.3
                  ),
                  h3: TextStyle(
                    color: Colors.black87, 
                    fontSize: 20, 
                    fontWeight: FontWeight.w700, 
                    height: 1.5 
                  ),
                  p: const TextStyle(
                    color: Color(0xFF424242), 
                    fontSize: 17, 
                    height: 1.6 
                  ),
                  strong: TextStyle(
                    color: mainColor, 
                    fontWeight: FontWeight.bold
                  ),
                  listBullet: TextStyle(
                    color: mainColor, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                  blockquote: TextStyle(
                    color: mainColor.withOpacity(0.8), 
                    fontStyle: FontStyle.italic, 
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: mainColor, width: 4))
                  ),
                  blockquotePadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}