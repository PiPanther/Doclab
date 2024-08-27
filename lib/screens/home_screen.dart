import 'package:doclab/common/widgets/loader.dart';
import 'package:doclab/models/document_model.dart';
import 'package:doclab/models/error_model.dart';
import 'package:doclab/repository/auth_respository.dart';
import 'package:doclab/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    final snackBar = ScaffoldMessenger.of(context);
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackBar.showSnackBar(SnackBar(content: Text(errorModel.error)));
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () => createDocument(context, ref),
                icon: const Icon(
                  Icons.add,
                  color: Colors.deepPurpleAccent,
                )),
            IconButton(
                onPressed: () => signOut(ref),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.deepPurpleAccent,
                ))
          ],
        ),
        body: FutureBuilder(
            future: ref
                .watch(documentRepositoryProvider)
                .getDocuments(ref.watch(userProvider)!.token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Center(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  width: 600,
                  child: ListView.builder(
                      itemCount: snapshot.data!.data.length,
                      itemBuilder: (context, index) {
                        DocumentModel doc = snapshot.data!.data[index];
                        return InkWell(
                          onTap: () => navigateToDocument(context, doc.id),
                          child: SizedBox(
                            height: 50,
                            child: Card(
                              child: Center(
                                child: Text(
                                  doc.title,
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              );
            }));
  }
}
