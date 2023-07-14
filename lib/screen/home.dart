import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weight_tracker_app/screen/email_auth/login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  void logOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.popUntil(context, (route) => route.isFirst);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void saveData() {
    String name = nameController.text.trim();
    String weight = weightController.text.trim();

    nameController.clear();
    weightController.clear();

    if (name != "" && weight != "") {
      Map<String, dynamic> userData = {
        "name": name,
        "weight": weight,
      };
      FirebaseFirestore.instance.collection("users").add(userData);
      print("user created");
    } else {
      print("please fill all the fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weight Tracker App"),
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter Your Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  hintText: "Enter Your Weight",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  saveData();
                },
                child: const Text("Submit"),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userMap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            final id = snapshot.data!.docs[index].id;
                            return ListTile(
                              title: Text(userMap["name"]),
                              subtitle: Text(userMap["weight"]),
                              trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      deletById(id);
                                    });
                                  },
                                  icon: const Icon(Icons.delete)),
                            );
                          },
                        ),
                      );
                    } else {
                      return const Text("No Data!");
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void deletById(String id) async {
    await FirebaseFirestore.instance.collection("users").doc(id).delete();
    print(id);

    print("user id is deleted");
  }
}
