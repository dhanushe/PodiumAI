import 'package:flutter/material.dart';

class ExpandableCard extends StatefulWidget {
  final String header;
  final String collapsedContent;
  final IconData iconData;

  const ExpandableCard({
    Key? key,
    required this.header,
    required this.collapsedContent,
    this.iconData = Icons.expand_more,
  }) : super(key: key);

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.header),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : widget.iconData),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(widget.collapsedContent),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}