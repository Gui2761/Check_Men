import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/saude_homem_screen.dart';
import 'dart:convert';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _submit() async {
  
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackbar('Por favor, preencha todos os campos.', isError: true);
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final response = await auth.login(_identifierController.text, _passwordController.text);
    if (!mounted) return;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _showSnackbar('Login realizado com sucesso!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SaudeHomemScreen()),
      );
    } else {
      final data = json.decode(response.body);
      _showSnackbar('Erro: ${data['detail']}', isError: true);
    }
  }
  
  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
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
            'Bem vindo de volta',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bem-vindos de volta ao CheckMen. Divirtam-se!',
            style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                    // Correção aqui:
                    hintText: 'Seu e-mail ou nome de usuário',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    hintText: 'Sua senha',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              auth.animateForgotPasswordBox();
            },
            child: const Text(
              'Esqueceu sua senha?',
              style: TextStyle(color: Color(0xFF888888)),
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
                      'Login',
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