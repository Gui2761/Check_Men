import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/forgot_password_form.dart';
import '../widgets/login_form.dart';
import '../widgets/new_password_form.dart';
import '../widgets/registration_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // Altura da caixa, ajustada para os valores anteriores
    final double boxHeight = auth.isRegistrationBoxVisible ? 550 : 500;
    
    Widget currentBoxContent;
    if (auth.isRegistrationBoxVisible) {
      currentBoxContent = const RegistrationForm();
    } else if (auth.isForgotPasswordBoxVisible) {
      currentBoxContent = const ForgotPasswordForm();
    } else if (auth.isNewPasswordBoxVisible) {
      currentBoxContent = const NewPasswordForm();
    } else {
      currentBoxContent = const LoginForm();
    }

    double boxPosition;
    if (auth.isLoginBoxVisible || auth.isForgotPasswordBoxVisible || auth.isNewPasswordBoxVisible) {
      boxPosition = 0;
    } else if (auth.isRegistrationBoxVisible) {
      boxPosition = -30;
    } else {
      boxPosition = -500;
    }

    final bool shouldIgnorePointer = auth.isLoginBoxVisible || auth.isRegistrationBoxVisible || auth.isForgotPasswordBoxVisible || auth.isNewPasswordBoxVisible;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/fundo.png", fit: BoxFit.cover),
          ),

          Align(
            alignment: const Alignment(0, -0.7),
            child: Image.asset(
              "assets/logo.png",
              width: 550,
              height: 550,
              fit: BoxFit.contain,
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            bottom: boxPosition,
            left: 0,
            right: 0,
            child: Container(
              height: boxHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: currentBoxContent,
            ),
          ),

          IgnorePointer(
            ignoring: shouldIgnorePointer,
            child: AnimatedOpacity(
              opacity: shouldIgnorePointer ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: const Alignment(0, 0.4),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: auth.animateLoginBox,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B489A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),

          IgnorePointer(
            ignoring: shouldIgnorePointer,
            child: AnimatedOpacity(
              opacity: shouldIgnorePointer ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: const Alignment(0, 0.55),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?', style: TextStyle(color: Color(0xFF888888), fontSize: 16)),
                    TextButton(
                      onPressed: auth.animateRegistrationBox,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B489A)),
                      child: const Text('Inscrever-se', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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