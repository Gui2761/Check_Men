import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
// import 'package:google_fonts/google_fonts.dart'; // 🔴 Removido
import '../models/noticia_model.dart';
import '../services/news_service.dart';

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B489A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _goToHome,
        ),
        title: const Text(
          'Notícias',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchNoticiasForPage,
          ),
        ],
      ),
      body: FutureBuilder<NoticiaResponse>(
        future: _futureNoticias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            String errorMessage = 'Erro ao carregar notícias.';
            final dynamic error = snapshot.error; 
            if (error is Exception) {
              errorMessage = error.toString().replaceFirst('Exception: ', '');
            }
            return Center(child: Text(errorMessage));
          } else if (!snapshot.hasData || snapshot.data!.noticias.isEmpty) {
            return const Center(child: Text('Nenhuma notícia encontrada.'));
          }

          final responseData = snapshot.data!;
          final List<Noticia> noticias = responseData.noticias;
          final int totalNoticias = responseData.totalNoticias;
          final int totalPages = (totalNoticias / _noticiasPerPage).ceil();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: noticias.length,
                  itemBuilder: (context, index) {
                    return _buildNoticiaCard(noticias[index]);
                  },
                ),
              ),
              SafeArea(
                top: false, 
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _currentPage > 1 ? _goToPreviousPage : null,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _currentPage > 1 ? const Color(0xFF3B489A).withOpacity(0.1) : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, 
                            size: 18,
                            color: _currentPage > 1 ? const Color(0xFF3B489A) : Colors.grey[300]
                          ),
                        ),
                      ),
                      
                      Text(
                        'Página $_currentPage de $totalPages',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                      ),

                      InkWell(
                        onTap: _currentPage < totalPages ? () => _goToNextPage(totalNoticias) : null,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _currentPage < totalPages ? const Color(0xFF3B489A).withOpacity(0.1) : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, 
                            size: 18,
                            color: _currentPage < totalPages ? const Color(0xFF3B489A) : Colors.grey[300]
                          ),
                        ),
                      ),
                    ],
                  ),
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
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: noticia.imageUrl.isNotEmpty
                  ? Image.network(
                      noticia.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noticia.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.3
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
                        fontSize: FontSize(13),
                        color: Colors.black54,
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      "a": Style(
                        color: const Color(0xFF3B489A),
                        textDecoration: TextDecoration.none,
                        fontWeight: FontWeight.bold
                      ),
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.source, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        Uri.parse(noticia.link).host.replaceFirst('www.', ''),
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/noticias_placeholder.png',
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}