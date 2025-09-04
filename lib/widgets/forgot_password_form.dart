import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _recoveryPhraseController = TextEditingController();

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await auth.forgotPassword(_recoveryPhraseController.text);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar('Verificação realizada! Redefina sua senha.');
        auth.animateNewPasswordBox();
      } else {
        final data = json.decode(response.body);
        _showSnackbar('Erro: ${data['message']}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro de conexão: ${e.toString()}', isError: true);
    }
  }

  @override
  void dispose() {
    _recoveryPhraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recupere a sua senha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          const Text(
            'Digite sua palavra de recuperação para trocar de senha!',
            style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: TextFormField(
              controller: _recoveryPhraseController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                hintText: 'Sua palavra recuperação',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B489A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: auth.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Recuperar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => auth.backToInitialScreen(context),
              child: const Text(
                'Voltar',
                style: TextStyle(color: Color(0xFF3B489A), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}