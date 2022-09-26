import 'package:dio/dio.dart';
import 'package:flutter_oss_aliyun/src/oss_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

void main() {
  test("test the put object in Client", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final Response<dynamic> resp = await OSSClient().putObject("Hello World".codeUnits, "test.txt");

    expect(200, resp.statusCode);
  });

  test("test the get object in Client", () async {
    OSSClient.init(
        ossEndpoint: "oss-cn-beijing.aliyuncs.com",
        bucketName: "back_name",
        tokenGetter: () => Future.value('''{
        "AccessKeyId": "access id",
        "AccessKeySecret": "AccessKeySecret",
        "SecurityToken": "security token",
        "Expiration": "2022-03-22T11:33:06Z"
       }'''));

    final Response<dynamic> resp = await OSSClient().getObject("test.txt");

    expect(200, resp.statusCode);
  });

  test("test the download object in Client", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final Response resp = await OSSClient().downloadObject("test.txt", "result.txt");

    expect(200, resp.statusCode);
  });

  test("test the delete object in Client", () async {
    OSSClient.init(
      stsUrl: "**",
      ossEndpoint: "oss-cn-beijing.aliyuncs.com",
      bucketName: "**",
    );

    final Response<dynamic> resp = await OSSClient().deleteObject("test.txt");

    expect(204, resp.statusCode);
  });
}
