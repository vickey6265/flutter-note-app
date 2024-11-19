import 'package:first_flutter/home_page.dart';
import 'package:first_flutter/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

import 'db_provider.dart';

class ViewNote extends StatefulWidget {
  final String heroTag;
  final String tag;
  final String title;
  final String desc;
  final int sno;
  final String mTime;
  final Color selectedNoteColor;
  final String mCompleted;

  const ViewNote({
    super.key,
    required this.heroTag,
    this.tag = "",
    this.sno = 0,
    this.title = "",
    this.desc = "",
    this.mTime = "",
    this.selectedNoteColor = Colors.white,
    this.mCompleted = '', // Default color
  });

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: widget.selectedNoteColor,
      appBar: appBarWidget(themeProvider),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            viewNoteDetailsWidget(themeProvider),
            noteMarkAsReadButtonWidget(themeProvider),
          ],
        ),
      ),
    );
  }

  //#region App Bar Widget
  appBarWidget(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: widget.selectedNoteColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              iconSize: 40,
              padding: EdgeInsets.zero,
              // Remove default padding
              alignment: Alignment.center,
              //
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              iconSize: 25,
              padding: EdgeInsets.zero,
              // Remove default padding
              alignment: Alignment.center,
              //
              color: widget.selectedNoteColor,
              onPressed: () {
                context.read<DBProvider>().deleteNote(widget.sno);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Note deleted")),
                );
                // Navigate back to the previous screen
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //#endregion

  //#region view note details Widget
  viewNoteDetailsWidget(ThemeProvider themeProvider) {
    return Expanded(
      // This allows the content to take available space and scroll
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: themeProvider.customFontsMerriweather(
                  45, 'bold', Colors.black),
            ),
            themeProvider.heightWidget(heightValue: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    widget.tag,
                    style: themeProvider.customFontsRoboto(
                        16, 'bold', Colors.black),
                  ),
                ),
                Text(
                  "Created on: \n${widget.mTime}",
                  style: themeProvider.customFontsRoboto(
                      18, 'normal', Colors.black),
                ),
              ],
            ),
            themeProvider.heightWidget(heightValue: 20),
            const Divider(
              color: Colors.black26,
              thickness: 1.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            themeProvider.heightWidget(heightValue: 20),
            Text(
              "Description:",
              style:
                  themeProvider.customFontsRoboto(18, 'normal', Colors.black),
            ),
            themeProvider.heightWidget(heightValue: 20),
            Text(
              widget.desc,
              style:
                  themeProvider.customFontsRoboto(22, 'normal', Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  //#region note mark as completed action button
  noteMarkAsReadButtonWidget(ThemeProvider themeProvider) {
    return Center(
      child: SliderButton(
        backgroundColor: Colors.black,
        buttonSize: 55,
        action: () async {
          try {
            if (widget.mCompleted == 'true') {
              await context.read<DBProvider>().markAsCompletedNote(widget.sno, 'false');
              if (!mounted) return null; // Check if the widget is still mounted
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note marked as Active")),
              );
            } else {
              await context.read<DBProvider>().markAsCompletedNote(widget.sno, 'true');
              if (!mounted) return null; // Check if the widget is still mounted
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Note marked as Completed")),
              );
            }

            // Navigate to HomePage
            if (mounted) { // Check again before navigation
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          } catch (e) {
            if (mounted) { // Ensure context is still valid for showing the snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to mark note as active/completed")),
              );
            }
          }
          return null; // Return null to satisfy the return type
        },
        // action: () async {
        //   if (widget.mCompleted == 'true') {
        //     try {
        //       await context
        //           .read<DBProvider>()
        //           .markAsCompletedNote(widget.sno, 'false');
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("Note marked as Active")),
        //       );
        //
        //       // Navigate to HomePage
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(builder: (context) => const HomePage()),
        //       );
        //     } catch (e) {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("Failed to mark note as active")),
        //       );
        //     }
        //     return;
        //   } else {
        //     try {
        //       await context
        //           .read<DBProvider>()
        //           .markAsCompletedNote(widget.sno, 'true');
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("Note marked as Completed")),
        //       );
        //
        //       // Navigate to HomePage
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(builder: (context) => const HomePage()),
        //       );
        //     } catch (e) {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //             content: Text("Failed to mark note as completed")),
        //       );
        //     }
        //   }
        //   return null;
        // },
        label: () {
          if (widget.mCompleted == 'true') {
            return const Text(
              "Slide to mark as Active",
              style: TextStyle(color: Colors.grey),
            );
          } else {
            return const Text(
              "Slide to mark as Complete",
              style: TextStyle(color: Color(0xff4a4a4a)),
            );
          }
        }(),
        icon: const Center(
          child: Icon(
            Icons.check,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        boxShadow: BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
        ),
        height: 70,
        highlightedColor: Colors.white,
        baseColor: Colors.white70,
      ),
    );
  }
  //#endregion
}
