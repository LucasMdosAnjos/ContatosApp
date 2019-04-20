import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  Contact _editedContact;
  bool _userEditted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      if(widget.contact == null)
      {
        _editedContact = Contact();
      }else
      {
        _editedContact = Contact.fromMap(widget.contact.toMap());
        _nameController.text = _editedContact.name;
        _emailController.text = _editedContact.email;
        _phoneController.text = _editedContact.telefone;
      }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
      appBar: AppBar(
        title: Text(_editedContact.name ?? "Novo contato"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(_editedContact.name !=null && _editedContact.name.isNotEmpty)
          {
            Navigator.pop(context, _editedContact);
          }else
          {
            FocusScope.of(context).requestFocus(_nameFocus);
          }
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child:  Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(shape: BoxShape.circle,
                image: DecorationImage(image: _editedContact.img !=null ? FileImage(File(_editedContact.img)) :
                 AssetImage("images/person.jpg"))),
              ),
              onTap: (){
                ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                  if(file == null)
                  {
                    return;
                  }else
                  {
                    setState(() {
                     _editedContact.img = file.path; 
                    });
                  }
                });
              },
            ),
            TextField(
              focusNode: _nameFocus,
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome"
              ),
              onChanged: (text)
              {
                _userEditted = true;
                setState(() {
                 _editedContact.name = text; 
                });
              },
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
              ),
              onChanged: (text)
              {
                 _editedContact.email = text; 
              },
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone"
              ),
              onChanged: (text)
              { 
                 _editedContact.telefone = text; 
              },
            )
          ],
        ),
      ),
    ),
    );
  }
  Future<bool>_requestPop()
  {
    if(_userEditted)
    {
      showDialog(context: context, 
      builder: (context)
      {
        return AlertDialog(

          title: Text("Descartar Alterações?"),
          content: Text("Se sair as alterações serão perdidas."),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
               onPressed: () {
                 Navigator.pop(context);
               },
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Sim"),
            ),
          ],
        );
      });
      return Future.value(false);
    }else
    {
      return Future.value(true);
    }
  }
}