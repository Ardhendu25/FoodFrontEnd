import 'dart:convert';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';
//import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';

/*var cloudinary = Cloudinary.fromStringUrl(
    'cloudinary://${dotenv.env["CLOUDINARY_API_KEY"]}:${dotenv.env["CLOUDINARY_API_SECRET"]}@${dotenv.env["CLOUDINARY_USER_NAME"]}');
*/

var cloudinary = Cloudinary.full(
  apiKey: dotenv.env["CLOUDINARY_API_KEY"].toString(),
  apiSecret: dotenv.env["CLOUDINARY_API_SECRET"].toString(),
  cloudName: dotenv.env["CLOUDINARY_USER_NAME"].toString(),
);

Future uploadCloud(image) async {
  var base64Img = await image.readAsBytes();
  var res = await cloudinary.uploadResource(CloudinaryUploadResource(
    filePath: image.path,
    fileBytes: base64Img,
    resourceType: CloudinaryResourceType.image,
    //folder: cloudinaryCustomFolder,
  ));

  /*cloudinary.config.urlConfig.secure = true;

  var base64Img = await image.readAsBytes();
  var type = image.mimeType!.split("/").last;
  var url = "data:image/${type};base64,${base64Encode(base64Img)}";

  var response = await cloudinary.uploader().upload(url);

  var image_url = response?.data?.secureUrl;*/
  if (res.isSuccessful) {
    return res.secureUrl;
  }
  return null;
}

Future destroyCloud(image) async {
  var res = await cloudinary.deleteResource(
      invalidate: false,
      url: image,
      resourceType: CloudinaryResourceType.image);
  return res;
}
