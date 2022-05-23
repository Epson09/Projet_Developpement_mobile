import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tp2/group_chats/group_info.dart';

class AjouterMembresGroup extends StatefulWidget {
  final String groupChatId, name;
  final List listMembres;
  const AjouterMembresGroup(
      {required this.name,
      required this.listMembres,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AjouterMembresGroupState createState() => _AjouterMembresGroupState();
}

class _AjouterMembresGroupState extends State<AjouterMembresGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = widget.listMembres;
  }

  void onAddMembers() async {
    membersList.add(userMap);

    await _firestore.collection('groupes').doc(widget.groupChatId).update({
      "membres": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['uid'])
        .collection('groupes')
        .doc(widget.groupChatId)
        .set({"name": widget.name, "id": widget.groupChatId});
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) =>
              GroupInfo(groupId: widget.groupChatId, groupName: widget.name)),
    );
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("username", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter Membres"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Rechercher l'id d'utilisateur",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: onSearch,
                    child: const Text("Rechercher"),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: const Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
