import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:share_plus/share_plus.dart';

class NotesScreen extends StatefulWidget {
  final String markdownData;

  NotesScreen({
    Key? key,
    required this.markdownData,
  }) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 35.0, top: 15.0, right: 35.0),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(-15, 0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: kPrimaryLight,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Text(
                      "Notes",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kPrimaryLight,
                      ),
                    ),
                    Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.share, color: kPrimaryDark),
                        onPressed: () {
                          // Generate Markdown file
                          print("Generating");
                          Share.share(widget.markdownData);
                        },
                        label: const Text(
                          'Export',
                          style: const TextStyle(
                            color: kPrimaryDark,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 35.0, top: 15.0, right: 35.0),
                child: GestureDetector(
                  onLongPress: () {},
                  onTap: () {},
                  child: MarkdownBody(
                    data: widget.markdownData,
                    selectable:
                        true, // Set to true if you want the text to be selectable
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 16.0, color: kPrimaryLight),
                      h1: Theme.of(context).textTheme.headline4?.copyWith(
                            color: kPrimaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                      h2: Theme.of(context).textTheme.headline5?.copyWith(
                            color: kPrimaryGreen,
                          ),
                      h3: Theme.of(context).textTheme.headline6?.copyWith(
                            color: kPrimaryPurple,
                            fontStyle: FontStyle.italic,
                          ),
                      em: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: kPrimaryPurple,
                            fontStyle: FontStyle.italic,
                          ),
                      strong: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: kPrimaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                      blockquote:
                          Theme.of(context).textTheme.bodyText1?.copyWith(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                      // bullet
                      listBullet:
                          Theme.of(context).textTheme.bodyText1?.copyWith(
                                color: kPrimaryPurple,
                              ),
                      // ordered list
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
