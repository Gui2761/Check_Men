// home_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Necessário para converter JSON

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variáveis para controlar a visibilidade das caixas
  bool _isLoginBoxVisible = false;
  bool _isRegistrationBoxVisible = false;
  bool _isForgotPasswordBoxVisible = false;
  bool _isNewPasswordBoxVisible = false;

  // Variáveis para controlar a visibilidade da senha
  bool _isLoginPasswordVisible = false;
  bool _isRegistrationPasswordVisible = false;
  bool _isRegistrationConfirmPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isNewPasswordConfirmVisible = false;

  // Variável para mostrar o indicador de carregamento
  bool _isLoading = false;

  // Controladores para cada campo de texto
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _registrationEmailController =
      TextEditingController();
  final TextEditingController _registrationPasswordController =
      TextEditingController();
  final TextEditingController _registrationConfirmPasswordController =
      TextEditingController();
  final TextEditingController _registrationRecoveryPhraseController =
      TextEditingController();
  final TextEditingController _forgotPasswordRecoveryPhraseController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();

  // Função para exibir mensagens na tela (Snackbar)
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Funções para lidar com as animações das caixas
  void _animateLoginBox() {
    setState(() {
      _isLoginBoxVisible = true;
      _isRegistrationBoxVisible = false;
      _isForgotPasswordBoxVisible = false;
      _isNewPasswordBoxVisible = false;
    });
  }

  void _animateRegistrationBox() {
    setState(() {
      _isRegistrationBoxVisible = true;
      _isLoginBoxVisible = false;
      _isForgotPasswordBoxVisible = false;
      _isNewPasswordBoxVisible = false;
    });
  }

  void _animateForgotPasswordBox() {
    setState(() {
      _isForgotPasswordBoxVisible = true;
      _isLoginBoxVisible = false;
      _isRegistrationBoxVisible = false;
      _isNewPasswordBoxVisible = false;
    });
  }

  void _animateNewPasswordBox() {
    setState(() {
      _isNewPasswordBoxVisible = true;
      _isForgotPasswordBoxVisible = false;
      _isLoginBoxVisible = false;
      _isRegistrationBoxVisible = false;
    });
  }

  void _backToInitialScreen() {
    setState(() {
      _isLoginBoxVisible = false;
      _isRegistrationBoxVisible = false;
      _isForgotPasswordBoxVisible = false;
      _isNewPasswordBoxVisible = false;
    });
  }

  // Funções para alternar a visibilidade das senhas
  void _toggleLoginPasswordVisibility() {
    setState(() {
      _isLoginPasswordVisible = !_isLoginPasswordVisible;
    });
  }

  void _toggleRegistrationPasswordVisibility() {
    setState(() {
      _isRegistrationPasswordVisible = !_isRegistrationPasswordVisible;
    });
  }

  void _toggleRegistrationConfirmPasswordVisibility() {
    setState(() {
      _isRegistrationConfirmPasswordVisible =
          !_isRegistrationConfirmPasswordVisible;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordVisible = !_isNewPasswordVisible;
    });
  }

  void _toggleNewPasswordConfirmVisibility() {
    setState(() {
      _isNewPasswordConfirmVisible = !_isNewPasswordConfirmVisible;
    });
  }

  // Função para lidar com o login (Rota para o Back-end)
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final email = _loginEmailController.text;
    final password = _loginPasswordController.text;

    try {
      final response = await http.post(
        Uri.parse(
          'https://seusite.com/api/login',
        ), // Substitua pela sua URL real
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Login realizado com sucesso!');
        // Aqui você pode navegar para a próxima tela do app
      } else {
        final data = json.decode(response.body);
        _showSnackbar('Erro: ${data['message']}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro de conexão: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para lidar com o registro (Rota para o Back-end)
  Future<void> _handleRegistration() async {
    setState(() {
      _isLoading = true;
    });

    final email = _registrationEmailController.text;
    final password = _registrationPasswordController.text;
    final confirmPassword = _registrationConfirmPasswordController.text;
    final recoveryPhrase = _registrationRecoveryPhraseController.text;

    // Validação básica da senha
    if (password != confirmPassword) {
      _showSnackbar('As senhas não coincidem.', isError: true);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://seusite.com/api/register',
        ), // Substitua pela sua URL real
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'recoveryPhrase': recoveryPhrase,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar('Usuário registrado com sucesso!');
      } else {
        final data = json.decode(response.body);
        _showSnackbar('Erro: ${data['message']}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro de conexão: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para lidar com a recuperação de senha (Rota para o Back-end)
  Future<void> _handleForgotPassword() async {
    setState(() {
      _isLoading = true;
    });

    final recoveryPhrase = _forgotPasswordRecoveryPhraseController.text;

    try {
      final response = await http.post(
        Uri.parse(
          'https://seusite.com/api/forgot-password',
        ), // Substitua pela sua URL real
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'recoveryPhrase': recoveryPhrase}),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Verificação realizada! Você pode redefinir sua senha.');
        _animateNewPasswordBox(); // Anima para a próxima tela
      } else {
        final data = json.decode(response.body);
        _showSnackbar('Erro: ${data['message']}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro de conexão: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para lidar com a definição de nova senha (Rota para o Back-end)
  Future<void> _handleNewPassword() async {
    setState(() {
      _isLoading = true;
    });

    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _newPasswordConfirmController.text;

    // Validação básica da nova senha
    if (newPassword != confirmNewPassword) {
      _showSnackbar('As senhas não coincidem.', isError: true);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://seusite.com/api/reset-password',
        ), // Substitua pela sua URL real
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Senha redefinida com sucesso!');
        _backToInitialScreen(); // Volta para a tela inicial
      } else {
        final data = json.decode(response.body);
        _showSnackbar('Erro: ${data['message']}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Erro de conexão: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Liberar controladores quando a tela é descartada
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registrationEmailController.dispose();
    _registrationPasswordController.dispose();
    _registrationConfirmPasswordController.dispose();
    _registrationRecoveryPhraseController.dispose();
    _forgotPasswordRecoveryPhraseController.dispose();
    _newPasswordController.dispose();
    _newPasswordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo da tela
          Positioned.fill(
            child: Image.asset("assets/fundo.png", fit: BoxFit.cover),
          ),

          // 2. Logo no topo
          Align(
            alignment: const Alignment(0, -0.9),
            child: Image.asset(
              "assets/logo.png",
              width: 550,
              height: 550,
              fit: BoxFit.contain,
            ),
          ),

          // 3.  A caixa branca de LOGIN
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            bottom: _isLoginBoxVisible ? 0 : -500,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bem vindo de volta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _loginEmailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Seu email',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                          TextFormField(
                            controller: _loginPasswordController,
                            obscureText: !_isLoginPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Sua senha',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isLoginPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleLoginPasswordVisibility,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _animateForgotPasswordBox,
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
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B489A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _backToInitialScreen,
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFF3B489A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. A caixa branca de REGISTRO
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            bottom: _isRegistrationBoxVisible ? 50 : -500,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Faça o seu registro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _registrationEmailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Seu email',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                          TextFormField(
                            controller: _registrationPasswordController,
                            obscureText: !_isRegistrationPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Sua senha',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isRegistrationPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    _toggleRegistrationPasswordVisibility,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                          TextFormField(
                            controller: _registrationConfirmPasswordController,
                            obscureText: !_isRegistrationConfirmPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Confirme a sua senha',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isRegistrationConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    _toggleRegistrationConfirmPasswordVisibility,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                          TextFormField(
                            controller: _registrationRecoveryPhraseController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey,
                              ),
                              hintText: 'Digite sua palavra recuperação',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
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
                        onPressed: _isLoading ? null : _handleRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B489A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Registrar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _backToInitialScreen,
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFF3B489A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. A caixa branca de RECUPERAÇÃO DE SENHA
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            bottom: _isForgotPasswordBoxVisible ? 0 : -500,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recupere a sua senha',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _forgotPasswordRecoveryPhraseController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                          hintText: 'Sua palavra recuperação',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B489A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Recuperar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _backToInitialScreen,
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFF3B489A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. A caixa branca de DEFINIR NOVA SENHA
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            bottom: _isNewPasswordBoxVisible ? 0 : -500,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Defina sua nova senha',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Sua nova senha',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleNewPasswordVisibility,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                          TextFormField(
                            controller: _newPasswordConfirmController,
                            obscureText: !_isNewPasswordConfirmVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              hintText: 'Repita a nova senha',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordConfirmVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleNewPasswordConfirmVisibility,
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
                        onPressed: _isLoading ? null : _handleNewPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B489A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Redefinir Senha',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _backToInitialScreen,
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFF3B489A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 7. Botão de login original (e "Não tem uma conta?")
          IgnorePointer(
            ignoring:
                _isLoginBoxVisible ||
                _isRegistrationBoxVisible ||
                _isForgotPasswordBoxVisible ||
                _isNewPasswordBoxVisible,
            child: AnimatedOpacity(
              opacity:
                  (_isLoginBoxVisible ||
                      _isRegistrationBoxVisible ||
                      _isForgotPasswordBoxVisible ||
                      _isNewPasswordBoxVisible)
                  ? 0.0
                  : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: const Alignment(0, 0.4),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _animateLoginBox,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B489A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 8. Texto "Não tem conta" original
          IgnorePointer(
            ignoring:
                _isLoginBoxVisible ||
                _isRegistrationBoxVisible ||
                _isForgotPasswordBoxVisible ||
                _isNewPasswordBoxVisible,
            child: AnimatedOpacity(
              opacity:
                  (_isLoginBoxVisible ||
                      _isRegistrationBoxVisible ||
                      _isForgotPasswordBoxVisible ||
                      _isNewPasswordBoxVisible)
                  ? 0.0
                  : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: const Alignment(0, 0.55),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 16),
                    ),
                    TextButton(
                      onPressed: _animateRegistrationBox,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B489A),
                      ),
                      child: const Text(
                        'Inscrever-se',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
