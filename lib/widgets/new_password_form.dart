import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';


class NewPasswordForm extends StatefulWidget {
  const NewPasswordForm({super.key});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> {
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isNewPasswordConfirmVisible = false;

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
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _showSnackbar('As senhas não coincidem.', isError: true);
      return;
    }
    final response = await auth.resetPassword(_newPasswordController.text);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _showSnackbar('Senha redefinida com sucesso!');
      auth.backToInitialScreen(context);
    } else {
      final data = json.decode(response.body);
      _showSnackbar('Erro: ${data['message']}', isError: true);
    }
  }
  
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
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
            'Defina sua nova senha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lembre-se da sua nova senha!',
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
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    hintText: 'Sua nova senha',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                ),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  obscureText: !_isNewPasswordConfirmVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    hintText: 'Repita a nova senha',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordConfirmVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isNewPasswordConfirmVisible = !_isNewPasswordConfirmVisible),
                    ),
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
                      'Redefinir Senha',
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