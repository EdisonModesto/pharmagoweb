import "package:flutter/material.dart";

class dialogUI extends StatelessWidget {
  const dialogUI({required this.title, required this.body, Key? key}) : super(key: key);
  final title;
  final body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: 250,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$title",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                  "$body"
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Close")
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}