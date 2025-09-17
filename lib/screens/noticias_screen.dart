import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../models/noticia_model.dart';
import '../services/news_service.dart';
// Importe sua tela Home, por exemplo:
// import 'home_screen.dart'; // Certifique-se de que o caminho está correto

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  final NewsService _newsService = NewsService();
  late Future<NoticiaResponse> _futureNoticias;
  int _currentPage = 1;
  final int _noticiasPerPage = 3; 

  @override
  void initState() {
    super.initState();
    _fetchNoticiasForPage();
  }

  void _fetchNoticiasForPage() {
    setState(() {
      _futureNoticias = _newsService.fetchNoticias(
        page: _currentPage,
        limit: _noticiasPerPage,
      );
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchNoticiasForPage();
    }
  }

  void _goToNextPage(int totalNoticias) {
    final int totalPages = (totalNoticias / _noticiasPerPage).ceil();
    if (_currentPage < totalPages) {
      setState(() {
        _currentPage++;
      });
      _fetchNoticiasForPage();
    }
  }

  void _goToHome() {
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B489A),
        foregroundColor: Colors.white,
        leadingWidth: 100, 
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goToHome,
              tooltip: 'Voltar para Home',
            ),
          ],
        ),
        title: const Text(
          'Notícias',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNoticiasForPage,
            tooltip: 'Recarregar Notícias',
          ),
        ],
      ),
      body: FutureBuilder<NoticiaResponse>(
        future: _futureNoticias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            String errorMessage = 'Erro ao carregar notícias. Tente novamente.';
            final dynamic error = snapshot.error; 
            if (error is Exception) {
              errorMessage = error.toString().replaceFirst('Exception: ', '');
            } else if (error != null) {
              errorMessage = error.toString();
            }
            return Center(child: Text(errorMessage));
          } else if (!snapshot.hasData || snapshot.data!.noticias.isEmpty) {
            return const Center(child: Text('Nenhuma notícia encontrada.'));
          }

          final NoticiaResponse responseData = snapshot.data!;
          final List<Noticia> noticias = responseData.noticias;
          final int totalNoticias = responseData.totalNoticias;
          final int totalPages = (totalNoticias / _noticiasPerPage).ceil();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: noticias.length,
                  itemBuilder: (context, index) {
                    return _buildNoticiaCard(noticias[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                      tooltip: 'Página Anterior',
                    ),
                    Text('Página $_currentPage de $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < totalPages ? () => _goToNextPage(totalNoticias) : null,
                      tooltip: 'Próxima Página',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoticiaCard(Noticia noticia) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(noticia.link);
          if (await url_launcher.canLaunchUrl(url)) {
            await url_launcher.launchUrl(url, mode: url_launcher.LaunchMode.externalApplication);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/noticias_placeholder.png',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noticia.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Html(
                    data: noticia.description.isEmpty 
                            ? '<p>Leia mais no link original.</p>'
                            : noticia.description,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      "a": Style(
                        color: Colors.blue,
                        textDecoration: TextDecoration.underline,
                      ),
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fonte: ${Uri.parse(noticia.link).host}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}