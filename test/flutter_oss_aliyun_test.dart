import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/asset_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

void main() {
  test("test the put object in OSSClient", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final Response<dynamic> resp =
        await OSSClient().putObject("Hello World".codeUnits, "test.txt");

    expect(200, resp.statusCode);
  });

  test("test the get object in OSSClient", () async {
    OSSClient.init(
        ossEndpoint: "oss-cn-beijing.aliyuncs.com",
        bucketName: "back_name",
        tokenGetter: () async => '''{
        "AccessKeyId": "access id",
        "AccessKeySecret": "AccessKeySecret",
        "SecurityToken": "security token",
        "Expiration": "2022-03-22T11:33:06Z"
       }''');

    final Response<dynamic> resp = await OSSClient().getObject("test.txt");

    expect(200, resp.statusCode);
  });

  test("test the download object in OSSClient", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final Response resp =
        await OSSClient().downloadObject("test.txt", "result.txt");

    expect(200, resp.statusCode);
  });

  test("test the delete object in OSSClient", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final Response<dynamic> resp = await OSSClient().deleteObject("test.txt");

    expect(204, resp.statusCode);
  });

  test("test the put objects in OSSClient", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final List<Response<dynamic>> resp = await OSSClient().putObjects([
      AssetEntity(filename: "filename1.txt", bytes: "files1".codeUnits),
      AssetEntity(filename: "filename2.txt", bytes: "files2".codeUnits),
    ]);

    expect(2, resp.length);
    expect(200, resp[0].statusCode);
    expect(200, resp[1].statusCode);
  });

  test("test the delete objects in OSSClient", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final List<Response<dynamic>> resp =
        await OSSClient().deleteObjects(["filename1.txt", "filename2.txt"]);

    expect(2, resp.length);
    expect(204, resp[0].statusCode);
    expect(204, resp[1].statusCode);
  });
}
