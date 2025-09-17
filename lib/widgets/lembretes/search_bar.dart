import 'package:flutter/material.dart';

class LembretesSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;

  const LembretesSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Pesquisa',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(30)),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(icon: const Icon(Icons.search, color: Colors.grey), hintText: hintText, hintStyle: const TextStyle(color: Colors.grey), border: InputBorder.none),
      ),
    );
  }
}