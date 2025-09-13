import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _recoveryPhraseController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty || _recoveryPhraseController.text.isEmpty) {
      _showSnackbar('Por favor, preencha todos os campos.', isError: true);
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text)) {
      _showSnackbar('Por favor, insira um e-mail válido.', isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackbar('As senhas não coincidem.', isError: true);
      return;
    }
    
    final response = await auth.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
      _recoveryPhraseController.text,
    );
    if (!mounted) return;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _showSnackbar('Usuário registrado com sucesso!');
      auth.backToInitialScreen(context);
    } else {
      final data = json.decode(response.body);
      _showSnackbar('Erro: ${data['message']}', isError: true);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _recoveryPhraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faça o seu registro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registre-se para aproveitar do CheckMen!',
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
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                      hintText: 'Seu nome de usuário',
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
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                      hintText: 'Seu email',
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      hintText: 'Confirme a sua senha',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                  ),
                  TextFormField(
                    controller: _recoveryPhraseController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                      hintText: 'Digite sua palavra recuperação',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                  ),
                ],
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
                        'Registrar',
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
      ),
    );
  }
}