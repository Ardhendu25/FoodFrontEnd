import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

Future getImage() async {
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage == null) return null;

  return pickedImage;
}
