import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:sports_iiitd/common/CustomAppbar.dart';
import 'package:sports_iiitd/common/colors.dart';
import 'package:sports_iiitd/common/dateUtil.dart';
import 'package:sports_iiitd/common/searchbar.dart';
import 'package:intl/intl.dart';
import '../services/db.dart';
import '../services/models.dart';
import 'register_sg.dart';

class SGs extends StatefulWidget {
  @override
  State<SGs> createState() => _SGsState();
}

class _SGsState extends State<SGs> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getStudentDocument(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasData) {
            return Center(
              child:
                  Text("No SPORT SGs", style: TextStyle(color: Colors.white)),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.fromLTRB(12, 60, 12, 0),
                color: Colors.black,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      customAppBar("SPORT SGs", context,
                          logo: true, goBack: false),
                      FutureBuilder(
                          future: getRunningSGs(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                !snapshot.hasData) {
                              return Center(
                                child: Text(
                                    "No Sport SGs are offered currently",
                                    style: TextStyle(color: Colors.white)),
                              );
                            } else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              List<SG> sgs = snapshot.data!;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  CustomSearchBar(onChanged: (value) {
                                    // setState(() {
                                    sgs = snapshot.data!
                                        .where((element) => element.name
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                    // });
                                  }),
                                  MonthlySGs(SGs: sgs),
                                ],
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                    ],
                  ),
                ),
              ),
              floatingActionButton: snapshot.data!.isSuperAdmin
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CreateSG()));
                      },
                      tooltip: 'Create SG',
                      child: const Icon(Icons.add),
                    )
                  : null,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class MonthlySGs extends StatefulWidget {
  List<SG> SGs = [];
  MonthlySGs({required this.SGs});
  @override
  State<MonthlySGs> createState() => _MonthlySGsState();
}

class _MonthlySGsState extends State<MonthlySGs> {
  @override
  Widget build(BuildContext context) {
    List<SG> SGs = widget.SGs;
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        itemCount: SGs.length,
        itemBuilder: (context, index) {
          SG sg = SGs[index];
          return SgWidget(
              sg: sg,
              uparWaaleKaSetState: () {
                setState(() {});
              });
        },
      ),
    );
  }
}

class SgWidget extends StatefulWidget {
  SgWidget({
    super.key,
    required this.sg,
    required this.uparWaaleKaSetState,
  });

  final SG sg;
  final Function uparWaaleKaSetState;

  @override
  State<SgWidget> createState() => _SgWidgetState();
}

class _SgWidgetState extends State<SgWidget> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // print(user);
    return Dismissible(
      key: Key(widget.sg.id),
      direction: widget.sg.participants.contains(user!.uid)
          ? DismissDirection.endToStart
          : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        print("object");
        if (direction == DismissDirection.endToStart) {
          print("swiped right");
          await unregisterForSG(widget.sg);
          widget.sg.participants.remove(user!.uid);
          widget.uparWaaleKaSetState();
        } else {
          print("swiped left");
          await registerForSG(widget.sg);
          widget.sg.participants.add(user!.uid);
          widget.uparWaaleKaSetState();
        }
        return false;
      },
      background: Container(
        color: widget.sg.participants.contains(user!.uid)
            ? Colors.red
            : Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: widget.sg.participants.contains(user!.uid)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.sg.participants.contains(user!.uid)
                    ? Icons.delete
                    : Icons.add,
                color: Colors.white,
              ),
              Text(
                widget.sg.participants.contains(user!.uid)
                    ? "Unregister"
                    : "Register",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      onDismissed: (DismissDirection direction) async {},
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon(IconlyBold.more_circle,
                //     color: const Color.fromARGB(255, 95, 22, 16)),
                Container(
                  width: 260,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Athletics Edge - " + widget.sg.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.sg.credits + " credits",
                          style: GoogleFonts.poppins(
                            color: CustomColors.golden,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                        "Deadline To Apply : " +
                            getReadableDate(widget.sg.deadline),
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 212, 209, 209),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ExpandableText(
                        widget.sg.description,
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 212, 209, 209),
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                        ),
                        expandText: "Read more",
                        collapseText: "Read Less",
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6),
                Image.asset(
                  "assets/" + 'sportscouncil_logo.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      "assets/logo.png",
                      width: MediaQuery.of(context).size.width * 0.2,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            widget.sg.participants.contains(user!.uid)
                ? Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade800, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        // stops: [0.3, 0.8],
                      ),
                    ),
                  )
                : Divider(),
          ],
        ),
      ),
    );
  }
}
