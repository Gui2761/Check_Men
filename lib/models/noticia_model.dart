class Noticia {
  final String title;
  final String description;
  final String link;
  final String imageUrl;

  Noticia({
    required this.title,
    required this.description,
    required this.link,
    this.imageUrl = '',
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

// NOVO MODELO PARA A RESPOSTA PAGINADA
class NoticiaResponse {
  final List<Noticia> noticias;
  final int totalNoticias;
  final int paginaAtual;
  final int noticiasPorPagina;

  NoticiaResponse({
    required this.noticias,
    required this.totalNoticias,
    required this.paginaAtual,
    required this.noticiasPorPagina,
  });

  factory NoticiaResponse.fromJson(Map<String, dynamic> json) {
    var noticiasList = json['noticias'] as List;
    List<Noticia> parsedNoticias = noticiasList.map((i) => Noticia.fromJson(i)).toList();

    return NoticiaResponse(
      noticias: parsedNoticias,
      totalNoticias: json['totalNoticias'] ?? 0,
      paginaAtual: json['paginaAtual'] ?? 1,
      noticiasPorPagina: json['noticiasPorPagina'] ?? 3,
    );
  }
}