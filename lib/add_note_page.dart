import 'package:first_flutter/db_provider.dart';
import 'package:first_flutter/theme_provider.dart';
import 'package:first_flutter/utils/get_time.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNotePage extends StatefulWidget {
  final bool isUpdate;
  final String tag;
  final String title;
  final String desc;
  final int sno;
  final String mTime;
  final Color selectedNoteColor;
  final String completed; // Add this variable

  const AddNotePage({
    super.key,
    this.isUpdate = false,
    this.tag = "",
    this.sno = 0,
    this.title = "",
    this.desc = "",
    this.mTime = "",
    this.selectedNoteColor = Colors.white, // Default color
    this.completed = 'false',
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final tagController = TextEditingController();
  String messageValidation = "";

  // State variable to track the selected color index
  int? selectedColorIndex;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and selected color index
    titleController.text = widget.title;
    descController.text = widget.desc;
    tagController.text = widget.tag;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (widget.isUpdate) {
      selectedColorIndex = NoteColor.values.indexWhere(
        (color) =>
            themeProvider.getNoteColor(color) == widget.selectedNoteColor,
      );
    } else {
      selectedColorIndex = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.mainBGColor,
      appBar: appBarWidget(themeProvider),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///created on Row Widget
              createdOnRowWidget(themeProvider),
              Visibility(
                visible: widget.isUpdate ? true : false,
                child: const SizedBox(height: 30),
              ),

              ///tag text field
              tagTextField(themeProvider),
              const SizedBox(
                height: 22,
              ),

              ///heading text field
              headingTextField(themeProvider),
              const SizedBox(height: 22),

              ///description text field
              descriptionTextField(themeProvider),
              const SizedBox(height: 30),
              // Color selection section
              Text(
                "Set note color",
                style: TextStyle(color: themeProvider.colorWhite),
              ),
              const SizedBox(
                height: 15,
              ),

              ///set note color widget
              setNoteColorWidget(themeProvider),
              const SizedBox(
                height: 25,
              ),

              ///note action button
              noteActionButtons(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  //#region App Bar
  ///app bar widget
  appBarWidget(themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.mainBGColor,
      automaticallyImplyLeading: false,
      title: widget.isUpdate
          ? Text(
              "Update Note",
              style: themeProvider.customFontsRoboto(
                  20, 'bold', themeProvider.colorPrimary),
              textAlign: TextAlign.start,
            )
          : Text(
              "Add New Note",
              style: themeProvider.customFontsRoboto(
                  20, 'bold', themeProvider.colorPrimary),
            ),
      actions: [
        Row(
          children: [
            Visibility(
              visible: widget.isUpdate ? true : false,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.red.shade100,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  // Search icon
                  onPressed: () {
                    context.read<DBProvider>().deleteNote(widget.sno);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Note deleted")),
                    );
                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  //#endregion

  //#region Header UI Widget
  ///created on Row Widget
  createdOnRowWidget(themeProvider) {
    return Row(
      children: [
        Visibility(
          visible: widget.isUpdate ? true : false,
          child: Text(
            "Created On:",
            style: TextStyle(color: themeProvider.colorWhite),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          widget.mTime,
          style: TextStyle(
            fontSize: 20,
            color: themeProvider.colorWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

//#endregion

  //#region Note Tag Field Widget
  ///tag text field
  tagTextField(themeProvider) {
    return TextField(
      style: TextStyle(color: themeProvider.colorWhite),
      controller: tagController,
      decoration: InputDecoration(
        label: Text(
          widget.isUpdate ? "Update tag" : "Add tag",
          style: TextStyle(color: themeProvider.colorWhite),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.colorPrimary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.colorWhite,
          ),
        ),
      ),
    );
  }

//#endregion

  //#region Note Heading Field Widget
  ///heading text field
  headingTextField(themeProvider) {
    return TextField(
      style: TextStyle(color: themeProvider.colorWhite),
      controller: titleController,
      decoration: InputDecoration(
        label: Text(
          widget.isUpdate ? "Update heading" : "Enter heading",
          style: TextStyle(color: themeProvider.colorWhite),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.colorPrimary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.colorWhite,
          ),
        ),
      ),
    );
  }

//#endregion

  //#region Note Description Field Widget
  ///description text field
  descriptionTextField(themeProvider) {
    return TextField(
      style: TextStyle(color: themeProvider.colorWhite),
      controller: descController,
      maxLines: 10,
      decoration: InputDecoration(
        label: Text(
          widget.isUpdate ? "Update description" : "Enter description",
          style: TextStyle(color: themeProvider.colorWhite),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.colorPrimary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.colorWhite,
          ),
        ),
      ),
    );
  }

//#endregion

  //#region note color selection widget
  ///set note color widget
  setNoteColorWidget(themeProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(NoteColor.values.length, (index) {
        NoteColor noteColor = NoteColor.values[index];
        return InkWell(
          onTap: () {
            setState(() {
              selectedColorIndex = index; // Update the selected color index
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeProvider.getNoteColor(noteColor),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: (selectedColorIndex == index ||
                    (selectedColorIndex == null &&
                        noteColor == NoteColor.white))
                ? const Icon(Icons.check,
                    color: Colors.black) // Checkmark for selected color
                : null, // No icon if not selected
          ),
        );
      }),
    );
  }

//#endregion

  //#region note action buttons
  ///note action buttons
  noteActionButtons(themeProvider) {
    return Row(
      children: [
        ///cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              descController.clear();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white), // Border color
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 15),

        ///create / update note cta
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30), // Set the border radius
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12), // Optional padding
            ),
            onPressed: () async {
              var noteTitle = titleController.text;
              var noteDesc = descController.text;
              var noteTag = tagController.text;
              var noteTime = getFormattedDate();
              var noteCompleted = widget.completed.toString();

              if (noteTitle.isNotEmpty &&
                  noteDesc.isNotEmpty &&
                  noteTag.isNotEmpty) {
                Color selectedNoteColor = themeProvider
                    .getNoteColor(NoteColor.values[selectedColorIndex!]);
                if (widget.isUpdate) {
                  context.read<DBProvider>().updateNote(
                        noteTitle,
                        noteTag,
                        noteDesc,
                        noteTime,
                        widget.sno,
                        selectedNoteColor,
                        noteCompleted,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Note Updated")),
                  );
                } else {
                  context.read<DBProvider>().addNote(
                        noteTitle,
                        noteTag,
                        noteDesc,
                        noteTime,
                        selectedNoteColor,
                        'false',
                      );
                }
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text("Please fill all required fields!!"),
                  ),
                );
              }
              titleController.clear();
              descController.clear();
            },
            child: Text(
              widget.isUpdate ? "Save Note" : "Create Note",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
//#endregion
}
