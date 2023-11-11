import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController contactcontroller = TextEditingController();
  List<Contact> contacts = List.empty(growable: true);
  Contact? recentlyDeleteContact;
  int recentlyDeletedindex = -1;
  int selectedindex = -1;
  late SharedPreferences sp;
  getSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
    readFromSp();
  }

  saveIntoSp() {
    List<String> contactListString =
        contacts.map((contact) => jsonEncode(contact.toJson())).toList();
    sp.setStringList("mydata", contactListString);
  }

  readFromSp() {
    List<String>? contactListString = sp.getStringList("mydata");
    if (contactListString != null) {
      contacts = contactListString
          .map((contact) => Contact.fromJson(json.decode(contact)))
          .toList();
    }
    setState(() {});
  }

  showSnackbarWithUndo() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("deleted by mistake?"),
      action: SnackBarAction(
          label: "undo",
          onPressed: () {
            contacts.insert(recentlyDeletedindex, recentlyDeleteContact!);
            setState(() {});
            saveIntoSp();
          }),
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("contact list "),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: namecontroller,
              decoration: const InputDecoration(
                hintText: "contact name ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: contactcontroller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: "contact number:",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      String name = namecontroller.text.trim();
                      String contact = contactcontroller.text.trim();
                      if (name.isNotEmpty && contact.isNotEmpty) {
                        setState(() {
                          namecontroller.text = "";
                          contactcontroller.text = "";
                          contacts.add(Contact(name: name, contact: contact));
                        });
                        saveIntoSp();
                      }
                    },
                    child: const Text("save ")),
                ElevatedButton(
                    onPressed: () {
                      String name = namecontroller.text.trim();
                      String contact = contactcontroller.text.trim();
                      setState(
                        () {
                          if (name.isNotEmpty && contact.isNotEmpty) {
                            namecontroller.text = "";
                            contactcontroller.text = "";
                            contacts[selectedindex].name = name;
                            contacts[selectedindex].contact = contact;
                            selectedindex = -1;
                          }
                        },
                      );
                    },
                    child: const Text("Update")),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            contacts.isEmpty
                ? const Text("not contact yey", style: TextStyle(fontSize: 22))
                : Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) => getRow(index),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
        child: ListTile(
      leading: CircleAvatar(
          backgroundColor: index % 2 == 0 ? Colors.deepPurple : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(contacts[index].name![0],
              style: const TextStyle(fontWeight: FontWeight.bold))),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contacts[index].name!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            contacts[index].contact!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
      trailing: SizedBox(
        width: 70,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                namecontroller.text = contacts[index].name!;
                contactcontroller.text = contacts[index].contact!;
                setState(() {
                  selectedindex = index;
                });
              },
              child: const Icon(Icons.edit),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  recentlyDeleteContact = contacts[index];
                  recentlyDeletedindex = index;
                  contacts.removeAt(index);
                });
                saveIntoSp();
                showSnackbarWithUndo();
              },
              child: const Icon(Icons.delete),
            )
          ],
        ),
      ),
    ));
  }
}
