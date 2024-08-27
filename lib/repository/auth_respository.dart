import 'dart:convert';
import 'package:doclab/constants/constants.dart';
import 'package:doclab/models/error_model.dart';
import 'package:doclab/models/user_model.dart';
import 'package:doclab/repository/local_storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localstoragerepository: LocalStorageRepository()));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageRepository localstoragerepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localstoragerepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(error: "Something went wrong!", data: null);
    print('object');
    try {
      final user = await _googleSignIn.signIn();

      print('object');
      if (user != null) {
        final userAcc = UserModel(
            email: user.email,
            name: user.displayName ?? "",
            profilePic: user.photoUrl ?? "",
            uid: '',
            token: '');
        var res = await _client.post(Uri.parse("${host}/api//signup"),
            body: userAcc.toJson(),
            headers: {'Content-Type': 'application/json; charset=UTF-8'});

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            error = ErrorModel(data: newUser, error: null);
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            print('Something went wrong from auth_repo');
        }
      }
    } catch (e) {
      error = ErrorModel(data: null, error: e.toString());
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(error: "Something went wrong!", data: null);
    print('object');
    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        var res = await _client.get(Uri.parse("${host}/"), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        });

        switch (res.statusCode) {
          case 200:
            final newUser =
                UserModel.fromJson(jsonDecode(jsonDecode(res.body)['user']))
                    .copyWith(token: token);
            error = ErrorModel(data: newUser, error: null);
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            print('Something went wrong from auth_repo');
        }
      }
    } catch (e) {
      error = ErrorModel(data: null, error: e.toString());
    }
    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
