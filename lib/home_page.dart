import 'package:first_flutter/add_note_page.dart';
import 'package:first_flutter/data/local/db_helper.dart';
import 'package:first_flutter/db_provider.dart';
import 'package:first_flutter/theme_provider.dart';
import 'package:first_flutter/utils/get_time.dart';
import 'package:first_flutter/view_note.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var titleController = TextEditingController();
  var descController = TextEditingController();
  String messageValidation = "";
  String searchQuery = ""; // Variable to hold the search query
  bool isSearching = false;
  String selectedFilter = 'Active';
  String currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<DBProvider>().getInitialNotes();
  }

  final GlobalKey<NavigatorState> _nestedNavigatorKey =
  GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        if (isSearching && searchQuery.isEmpty) {
          setState(() {
            isSearching = false; // Hide search bar
          });
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: themeProvider.mainBGColor,
        appBar: appBarWidget(themeProvider),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Today, ${getFormattedDate()}",
                    style: themeProvider.customFontsMerriweather(
                        20, 'medium', themeProvider.colorWhite),
                  ),
                ],
              ),
              themeProvider.heightWidget(heightValue: 20),
              Expanded(
                /// Listing all notes
                child: listingNotes(themeProvider),
              ),
            ],
          ),
        ),
        floatingActionButton:
            floatingActionButtonWidget(themeProvider, context),
      ),
    );
  }

  //#region FloatingActionButton [add note]
  ///create note floating action button widget
  floatingActionButtonWidget(themeProvider, ctx) {
    return FloatingActionButton(
      onPressed: () async {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddNotePage()));
      },
      backgroundColor: themeProvider.colorWhite,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(Icons.add),
    );
  }

  //#endregion

  //#region App Bar
  ///app bar widget
  appBarWidget(themeProvider) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: themeProvider.mainBGColor,
      title: isSearching
          ? TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update the search query in real-time
                });
              },
              style: TextStyle(color: themeProvider.colorPrimary), // Text color
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: const TextStyle(color: Colors.white),
                // Hint text color
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.0), // White border for enabled state
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  // Same rounded corners for focused state
                  borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.0), // White border for focused state
                ),
                filled: true,
                fillColor: themeProvider.iconBgColor,
                // Background color
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              ),
            )
          : Text(
              getGreeting(),
              style: themeProvider.customFontsRoboto(
                  20, 'bold', themeProvider.colorPrimary),
              textAlign: TextAlign.start,
            ),
      actions: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: themeProvider.iconBgColor,
          ),
          child: IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: themeProvider.iconColor,
            ),
            // Search icon
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle search bar visibility
                if (!isSearching) {
                  searchQuery = ""; // Clear search query when closing
                }
              });
            },
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  //#endregion

  //#region listing note UI + logic
  ///listing all notes
  listingNotes(themeProvider) {
    return Consumer<DBProvider>(
      builder: (ctx, provider, __) {
        //#region filter notes logic
        // Access the notes from the provider.
        List<Map<String, dynamic>> allNotes = provider.getNotes();

        // Filter notes based on the selected filter
        List<Map<String, dynamic>> filteredNotes = [];

        if (currentFilter == 'All') {
          filteredNotes = allNotes;
        } else {
          filteredNotes = allNotes.where((note) {
            return (currentFilter == 'Active' &&
                    note[DBHelper.COLUMN_NOTE_COMPLETED] == 'false') ||
                (currentFilter == 'Completed' &&
                    note[DBHelper.COLUMN_NOTE_COMPLETED] == 'true');
          }).toList();
        }

        // Add your existing search query filter here
        if (searchQuery.isNotEmpty) {
          filteredNotes = filteredNotes.where((note) {
            return note[DBHelper.COLUMN_NOTE_TITLE]
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                note[DBHelper.COLUMN_NOTE_DESC]
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
          }).toList();
        }
        //#endregion

        //#region filter note action button
        filterButtons(filteredNotes) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF3C4171),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Visibility(
                visible: allNotes.isNotEmpty,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(30)),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentFilter = 'All'; // Show all notes
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove padding
                            backgroundColor: currentFilter == 'All'
                                ? const Color(0xFF4B88AB)
                                : const Color(0xFF3C4171),
                            elevation: 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          // Add padding for button content
                          child: Text(
                            'All',
                            style: themeProvider.customFontsRoboto(
                                14, 'medium', themeProvider.colorWhite),
                          ),
                        ),
                      ),
                    ),
                    // Middle Button - Square
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentFilter = 'Active'; // Show active notes
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove padding
                            backgroundColor: currentFilter == 'Active'
                                ? const Color(0xFF4B88AB)
                                : const Color(0xFF3C4171),
                            elevation: 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          // Add padding for button content
                          child: Text(
                            'Active',
                            style: themeProvider.customFontsRoboto(
                                14, 'medium', themeProvider.colorWhite),
                          ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(30)),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentFilter = 'Completed'; // Show all notes
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove padding
                            backgroundColor: currentFilter == 'Completed'
                                ? const Color(0xFF4B88AB)
                                : const Color(0xFF3C4171),
                            elevation: 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          // Add padding for button content
                          child: Text(
                            'Completed',
                            style: themeProvider.customFontsRoboto(
                                14, 'medium', themeProvider.colorWhite),
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
        //#endregion

        var mainAxisPosition = filteredNotes.isEmpty
            ? MainAxisAlignment.start
            : MainAxisAlignment.center;
        var crossAxisPosition = filteredNotes.isEmpty
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center;

        //#region listing all notes with empty state message hamdling
        return Column(
          mainAxisAlignment: mainAxisPosition,
          crossAxisAlignment: crossAxisPosition,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Notes",
                      style: themeProvider.customFontsRoboto(
                          18, 'medium', themeProvider.colorWhite),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: themeProvider.colorWhite),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        child: Center(
                          child: Text(
                            '${filteredNotes.length}',
                            style: themeProvider.customFontsRoboto(
                                18, 'medium', Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Text(
                //   'Notes (${filteredNotes.length})',
                //   style: themeProvider.customFontsMerriweather(
                //       18, 'medium', themeProvider.colorWhite),
                // ),
                filterButtons(filteredNotes),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 1.5,
              color: Colors.white38,
            ),
            const SizedBox(
              height: 10,
            ),
            filteredNotes.isNotEmpty
                ? Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredNotes.length,
                        itemBuilder: (_, index) {
                          final note = filteredNotes[index];
                          final heroTag =
                              'view_note_${note[DBHelper.COLUMN_NOTE_SNO]}';
                          return Dismissible(
                            key: Key(note[DBHelper.COLUMN_NOTE_SNO].toString()),
                            // Use a unique key
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(
                                    25), // Set border radius
                              ),
                              alignment: Alignment.centerLeft,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Icon(Icons.edit,
                                        color: Colors.white, size: 30),
                                  ),
                                  Text('Edit Note',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(
                                    25), // Set border radius
                              ),
                              alignment: Alignment.centerRight,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('Delete Note',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Icon(Icons.delete,
                                        color: Colors.white, size: 30),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                // Confirm deletion based on the platform
                                if (Theme.of(context).platform ==
                                    TargetPlatform.iOS) {
                                  return await showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: const Text('Are you sure?'),
                                        content: const Text(
                                            'Do you want to delete this note?'),
                                        actions: [
                                          CupertinoDialogAction(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          CupertinoDialogAction(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  return await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Are you sure?'),
                                      content: const Text(
                                          'Do you want to delete this note?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                }
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                // For edit action, return false to prevent dismiss
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNotePage(
                                      isUpdate: true,
                                      tag: note[DBHelper.COLUMN_NOTE_TAG],
                                      sno: note[DBHelper.COLUMN_NOTE_SNO],
                                      title: note[DBHelper.COLUMN_NOTE_TITLE],
                                      desc: note[DBHelper.COLUMN_NOTE_DESC],
                                      mTime: note[DBHelper.COLUMN_NOTE_TIME],
                                      selectedNoteColor: Color(
                                        int.parse(
                                            note[DBHelper.COLUMN_NOTE_COLOR],
                                            radix: 16),
                                      ),
                                      completed:
                                          note[DBHelper.COLUMN_NOTE_COMPLETED],
                                    ),
                                  ),
                                );
                                return false; // Prevent dismissal for edit action
                              }
                              return false; // Default return for other cases
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                // Delete note
                                provider
                                    .deleteNote(note[DBHelper.COLUMN_NOTE_SNO]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Note deleted')));
                              }
                              // No action needed for the edit direction as it is handled in confirmDismiss
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewNote(
                                      heroTag: heroTag,
                                      tag: note[DBHelper.COLUMN_NOTE_TAG],
                                      sno: note[DBHelper.COLUMN_NOTE_SNO],
                                      title: note[DBHelper.COLUMN_NOTE_TITLE],
                                      desc: note[DBHelper.COLUMN_NOTE_DESC],
                                      mTime: note[DBHelper.COLUMN_NOTE_TIME],
                                      selectedNoteColor: Color(int.parse(
                                          note[DBHelper.COLUMN_NOTE_COLOR],
                                          radix: 16)),
                                      mCompleted:
                                          note[DBHelper.COLUMN_NOTE_COMPLETED],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: const Offset(
                                            0, 4), // Shadow position
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(25),
                                    color: Color(int.parse(
                                        filteredNotes[index]
                                            [DBHelper.COLUMN_NOTE_COLOR],
                                        radix: 16)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 5, right: 5, bottom: 0),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(5),
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          filteredNotes[index]
                                              [DBHelper.COLUMN_NOTE_TITLE],
                                          style: themeProvider
                                              .customFontsMerriweather(
                                                  22, 'bold', Colors.black),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  filteredNotes[index][DBHelper
                                                      .COLUMN_NOTE_COLOR],
                                                  radix: 16)),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                            child: Text(
                                              filteredNotes[index]
                                                  [DBHelper.COLUMN_NOTE_TAG],
                                              style: themeProvider
                                                  .customFontsRoboto(10,
                                                      'normal', Colors.black),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${filteredNotes[index][DBHelper.COLUMN_NOTE_DESC]}",
                                            style: themeProvider
                                                .customFontsRoboto(
                                                    16, 'normal', Colors.black)
                                                .copyWith(
                                                  decoration: filteredNotes[
                                                                  index]
                                                              ['completed'] ==
                                                          'true'
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                                ),
                                            maxLines: 3, // Limit to 3 lines
                                            overflow: TextOverflow
                                                .ellipsis, // Show ellipsis
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            filteredNotes[index][DBHelper
                                                        .COLUMN_NOTE_COMPLETED] ==
                                                    'true'
                                                ? "Completed On: ${filteredNotes[index][DBHelper.COLUMN_NOTE_TIME].toString()}"
                                                : "Created On: ${filteredNotes[index][DBHelper.COLUMN_NOTE_TIME].toString()}",
                                            style:
                                                themeProvider.customFontsRoboto(
                                                    12, 'normal', Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Expanded(
                    flex: 2,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (currentFilter == 'Completed' &&
                              filteredNotes.isEmpty) ...[
                            SizedBox(
                              height: 80,
                              child:
                                  Image.asset('assets/images/empty_note.png'),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No completed notes found!",
                              style: themeProvider.customFontsMerriweather(
                                  22, 'bold', themeProvider.colorPrimary),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "You haven't marked any notes as completed yet.",
                              style: themeProvider.customFontsMerriweather(
                                  15, 'normal', themeProvider.colorPrimary),
                              textAlign: TextAlign.center,
                            ),
                          ] else if (currentFilter == 'Active' &&
                              filteredNotes.isEmpty) ...[
                            SizedBox(
                              height: 80,
                              child:
                                  Image.asset('assets/images/empty_note.png'),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "You have no active notes!",
                              style: themeProvider.customFontsMerriweather(
                                  22, 'bold', themeProvider.colorPrimary),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Tap '+' to create an active note.",
                              style: themeProvider.customFontsMerriweather(
                                  15, 'normal', themeProvider.colorPrimary),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            // Original empty state logic
                            SizedBox(
                              height: 80,
                              child:
                                  Image.asset('assets/images/empty_note.png'),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              searchQuery.isNotEmpty
                                  ? "No notes found!"
                                  : "No notes yet!",
                              style: themeProvider.customFontsMerriweather(
                                  22, 'bold', themeProvider.colorPrimary),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              searchQuery.isNotEmpty
                                  ? "Try searching for a different word."
                                  : "Tap the ‘+’ button to start capturing your notes.",
                              style: themeProvider.customFontsMerriweather(
                                  15, 'normal', themeProvider.colorPrimary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ],
        );
        //#endregion
      },
    );
  }
//#endregion
}
