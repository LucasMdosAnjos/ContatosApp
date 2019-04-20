import 'dart:io';
import 'package:agenda_contatos/UI/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz,orderza}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context)=><PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.orderaz,

              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context,index){
          return _contactCard(context, index);
        },
      ),
    );
  }
  Widget _contactCard(BuildContext context, int index)
  {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(shape: BoxShape.circle,
                image: DecorationImage(image: contacts[index].img !=null ? FileImage(File(contacts[index].img)) :
                 AssetImage("images/person.jpg"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "",style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold)),
                    Text(contacts[index].email ?? "",style: TextStyle(fontSize: 18.0)),
                    Text(contacts[index].telefone ?? "",style: TextStyle(fontSize: 18.0))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){ 
       _showOptions(context,index);
      },
    );
  }
  void _showOptions(BuildContext context, int index)
  {
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    child: Text('Ligar',style: TextStyle(
                      color: Colors.red,fontSize: 20.0
                    ),
                    ),onPressed: (){
                      launch("tel:${contacts[index].telefone}");
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('Editar',style: TextStyle(
                      color: Colors.red,fontSize: 20.0
                    ),
                    ),onPressed: (){
                      Navigator.pop(context);
                      _showContactPage(contact: contacts[index]);
                    },
                  ),
                  FlatButton(
                    child: Text('Excluir',style: TextStyle(
                      color: Colors.red,fontSize: 20.0
                    ),
                    ),
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (context)
                        {
                          return AlertDialog(
                            title: Text('Deseja remover este item?'),
                            actions: <Widget>[
                              FlatButton(
                                textColor: Colors.cyan,
                                 child: Text('Cancelar'),
                                 onPressed: (){
                                    for(int i = 0;i<2;i++)
                                   {
                                     Navigator.pop(context);
                                   }
                                 },
                              ),
                              FlatButton(
                                textColor: Colors.cyan,
                                child: Text('Sim'),
                                onPressed: (){
                                  helper.deleteContact(contacts[index].id);
                                  setState(() {
                                   contacts.removeAt(index);
                                   for(int i = 0;i<2;i++)
                                   {
                                     Navigator.pop(context);
                                   }
                                  });
                                },
                              )
                            ],
                          );
                        }
                      );
                    },
                  ),
                ],
              ),
            );
          }, onClosing: () {},
        );
      }
    );
  }
  void _showContactPage({Contact contact}) async
  {
    final recContact = await Navigator.push(context,MaterialPageRoute(builder: (context)=>ContactPage(contact: contact,)));
    if(recContact !=null)
    {
      if(contact!=null)
      {
        await helper.updateContact(recContact);
        _getAllContacts();
      }else
      {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
  void _getAllContacts(){
    helper.getAllContacts().then((list)
    {
      setState(() {
         contacts = list;
      });
    });
  }
  void _orderList(OrderOptions result)
  {
    switch(result)
    {
      case OrderOptions.orderaz:
      contacts.sort((a, b){
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      break;
      case OrderOptions.orderza:
      contacts.sort((b, a){
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      break;
    }
    setState(() {
      
    });
  }
}