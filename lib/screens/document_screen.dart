import 'package:doclab/colors.dart';
import 'package:doclab/models/document_model.dart';
import 'package:doclab/models/error_model.dart';
import 'package:doclab/repository/auth_respository.dart';
import 'package:doclab/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titlecontroller =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController _controller = quill.QuillController.basic();
  ErrorModel? errorModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDocumentData();
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);
    if (errorModel!.data != null) {
      titlecontroller.text = (errorModel!.data as DocumentModel).title;
       setState(() {
         
       });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    titlecontroller.dispose();
    _controller.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: KWhiteColor,
          elevation: 0,
          title: Row(
            children: [
              const Icon(
                Icons.document_scanner,
                size: 16,
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: titlecontroller,
                  onSubmitted: (value) => updateTitle(ref, value),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
              )
            ],
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.1)),
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              quill.QuillSimpleToolbar(
                controller: _controller,
                configurations: const quill.QuillSimpleToolbarConfigurations(),
              ),
              Expanded(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: quill.QuillEditor.basic(
                        controller: _controller,
                        configurations: const quill.QuillEditorConfigurations(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
