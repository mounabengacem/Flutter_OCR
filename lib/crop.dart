import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImageCropper',
      theme: ThemeData.light().copyWith(primaryColor: Colors.deepOrange),
      home: MyHomePage(
        title: 'ImageCropper',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppState {
  free,
  picked,
  cropped,
}
 
class _MyHomePageState extends State<MyHomePage> {
  AppState state;
  File imageFile;
 bool _scanning = false; 
  String  _extText ='';
   

  @override
  void initState() {
    super.initState();
    state = AppState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _decideImageView()// imageFile != null ? Image.file(imageFile) : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == AppState.free)
            _pickImage();
          else if (state == AppState.picked)
            _cropImage();
          else if (state == AppState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery  );
    final File picture = File(pickedFile.path);
    //imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    //if (imageFile != null) {
      setState(() {
        state = AppState.picked;
       imageFile= picture;
     });
           
    //}
  }
  Widget _decideImageView(){
    if (imageFile == null)
    { return Text("No image selected",); }
     
    else if(_scanning == false ){
      return  Image.file(imageFile,width:400,height:400);
       
    }
    else{
     print(imageFile.path);  
     //GallerySaver.saveImage(imageFile.path);
     print(_scanning);
     return Text(
              _extText,
              textAlign: TextAlign.center,
             style: TextStyle(
               fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            );
    }
  }
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));

        if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
        _scanning = true;
      //  _extText=_extractText;
      });
        
    
        
      
    }
  }

  void _clearImage() async{
    var _extractText = await TesseractOcr.extractText(imageFile.path);
    print(_extractText)  ; 

    //imageFile = null;
    
    setState(() {
      _scanning = true ; 
     _extText =_extractText ;
      //state = AppState.free;
    });
  }
}
