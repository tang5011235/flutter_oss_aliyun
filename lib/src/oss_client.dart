import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/request.dart';
import 'package:mime_type/mime_type.dart';

import 'auth.dart';
import 'dio_client.dart';
import 'encrypt.dart';

class OSSClient {
  static OSSClient? _instance;

  factory OSSClient() => _instance!;

  final String endpoint;
  final String bucketName;
  final Function? tokenGetter;

  OSSClient._(
    this.endpoint,
    this.bucketName,
    this.tokenGetter,
  );

  static void init(
      {String? stsUrl,
      required String ossEndpoint,
      required String bucketName,
      Future<String> Function()? tokenGetter}) {
    assert(stsUrl != null || tokenGetter != null);
    final tokenGet = tokenGetter ??
        () async {
          final response = await RestClient.getInstance().get<String>(stsUrl!);
          return response.data!;
        };
    _instance = OSSClient._(ossEndpoint, bucketName, tokenGet);
  }

  Auth? _auth;
  String? _expire;

  /// get auth information from sts server
  Future<Auth> _getAuth() async {
    if (_isNotAuthenticated()) {
      final resp = await tokenGetter!();
      final respMap = jsonDecode(resp);
      _auth = Auth(respMap['AccessKeyId'], respMap['AccessKeySecret'],
          respMap['SecurityToken']);
      _expire = respMap['Expiration'];
    }
    return _auth!;
  }

  /// get object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> getObject(String fileKey,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return RestClient.getInstance()
        .get(request.url, options: Options(headers: request.headers));
  }

  /// download object(file) from oss server
  /// [fileKey] is the object name from oss
  /// [savePath] is where we save the object(file) that download from oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response> downloadObject(String fileKey, String savePath,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'GET', {}, {});
    auth.sign(request, bucket, fileKey);

    return await RestClient.getInstance().download(request.url, savePath,
        options: Options(headers: request.headers));
  }

  /// upload object(file) to oss server
  /// [fileData] is the binary data that will send to oss server
  /// [bucketName] is optional, we use the default bucketName as we defined in Client
  Future<Response<dynamic>> putObject(List<int> fileData, String fileKey,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final Map<String, String> headers = {
      'content-md5': EncryptUtil.md5File(fileData),
      'content-type': mime(fileKey) ?? "image/png",
    };
    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(url, 'PUT', {}, headers);
    auth.sign(request, bucket, fileKey);

    return RestClient.getInstance().put(
      request.url,
      data: MultipartFile.fromBytes(fileData).finalize(),
      options: Options(headers: request.headers),
    );
  }

  /// delete object from oss
  Future<Response<dynamic>> deleteObject(String fileKey,
      {String? bucketName}) async {
    final String bucket = bucketName ?? this.bucketName;
    final Auth auth = await _getAuth();

    final String url = "https://$bucket.$endpoint/$fileKey";
    final HttpRequest request = HttpRequest(
        url, 'DELETE', {}, {'content-type': 'application/json; charset=utf-8'});
    auth.sign(request, bucket, fileKey);

    return RestClient.getInstance()
        .delete(request.url, options: Options(headers: request.headers));
  }

  /// whether auth is valid or not
  bool _isNotAuthenticated() {
    return _auth == null || _isExpired();
  }

  /// whether the auth is expired or not
  bool _isExpired() {
    return _expire == null || DateTime.now().isAfter(DateTime.parse(_expire!));
  }
}
