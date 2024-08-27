import 'dart:convert';

import 'package:doclab/constants/constants.dart';
import 'package:doclab/models/document_model.dart';
import 'package:doclab/models/error_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider = Provider(
  (ref) => DocumentRepository(
    client: Client(),
  ),
);

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(error: "Something went wrong!", data: null);
    print('object');
    try {
      var res = await _client.post(Uri.parse("${host}/doc/create"),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          }));

      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(data: DocumentModel.fromJson(res.body), error: null);
          break;
        default:
          error = ErrorModel(data: null, error: res.body);
      }
    } catch (e) {
      error = ErrorModel(data: null, error: e.toString());
    }
    return error;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error = ErrorModel(error: "Something went wrong!", data: null);
    print('object');
    try {
      var res = await _client.get(
        Uri.parse("${host}/docs/me"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];

          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(
                DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          error = ErrorModel(data: documents, error: null);
          break;
        default:
          error = ErrorModel(data: null, error: res.body);
      }
    } catch (e) {
      error = ErrorModel(data: null, error: e.toString());
    }
    return error;
  }

  void updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    var res = await _client.post(Uri.parse("${host}/doc/title"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'title': title,
          'id': id,
        }));
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error = ErrorModel(error: "Something went wrong!", data: null);
    print('object');
    try {
      var res = await _client.get(
        Uri.parse("${host}/docs/$id"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(data: DocumentModel.fromJson(res.body), error: null);
          break;
        default:
          throw 'This document does not exist, Please create a new one.';
      }
    } catch (e) {
      error = ErrorModel(data: null, error: e.toString());
    }
    return error;
  }
}
