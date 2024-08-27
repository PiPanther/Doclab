import 'package:doclab/colors.dart';
import 'package:doclab/repository/auth_respository.dart';
import 'package:doclab/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    } else {
      sMessenger.showSnackBar(SnackBar(content: Text(errorModel.error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: ElevatedButton.icon(
            onPressed: () {
              print('Clicked');
              signInWithGoogle(ref, context);
            },
            label: const Text(
              'Sign in with Google',
              style: TextStyle(color: kBlackColor),
            ),
            icon: Image.asset(
              'assets/google.png',
              height: 25,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 50),
              backgroundColor: KWhiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
