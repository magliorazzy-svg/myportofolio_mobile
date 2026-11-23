Name : Maglio Razzy Effendy

NPM : 2506553616

Class : PBP Kelas Internasional

# myportofolio_mobile

The mobile client of my personal portfolio, built with Flutter. It is the Flutter
counterpart of my Django website ([myportofolio](https://github.com/magliorazzy-svg/myportofolio)),
which is a separate repository. The home screen (`lib/menu.dart`) shows three
`InfoCard`s with my NPM, name, and class, and a grid of six `ItemCard` buttons for my
portfolio sections (View Projects, View Achievements, View Experience, Add Project, Add
Achievement, Logout). Each button has its own colour and shows a `SnackBar` with
"You pressed the [button name] button!" when it is pressed. `lib/main.dart` only
contains the app bootstrap (`MyApp`, the theme) and the screen lives in `menu.dart`.

## How to Run Locally

```bash
flutter pub get
flutter run -d chrome
```

Other useful commands:

```bash
flutter analyze    # static analysis, should print "No issues found!"
flutter test       # widget tests
```

Flutter 3.47 (Dart 3.13) was used. Chrome is the run target; an Android emulator is
not required.

## Answers to the Reflective Questions

### Assignment 7

1. A widget tree is the hierarchy of widgets that describes the screen: everything in
   Flutter is a widget, and widgets are nested inside other widgets. A parent widget
   contains and configures its children (a `Column` lays out its `children`, a `Padding`
   wraps one `child`), while a child gets its size constraints from the parent and
   reports its size back. In this project, `MaterialApp` is the root, then `Scaffold`,
   then `SingleChildScrollView`, `Padding`, and `Column`, which holds a `Row` of
   `InfoCard`s and a `GridView` of `ItemCard`s. When something changes, Flutter rebuilds
   the affected part of this tree.

2. Widgets used: `MaterialApp` (app root, theme, and navigation setup), `Scaffold` (page
   structure with app bar and body), `AppBar` (top bar with the title), `Text` (shows
   text), `SingleChildScrollView` (makes the content scrollable), `Padding` (spacing
   around a child), `Column` and `Row` (vertical and horizontal layout), `Center`
   (centres a child), `SizedBox` (fixed empty space), `GridView.count` (grid with a fixed
   number of columns), `Card` and `Container` (box with elevation, size, and padding),
   `Material` (coloured surface with rounded corners), `InkWell` (tap detection with a
   ripple effect), `Icon` (shows an icon), `ScaffoldMessenger` and `SnackBar` (short
   message at the bottom), and my own `MyHomePage`, `InfoCard`, and `ItemCard`.

3. `MaterialApp` is the widget that sets up a Material Design app: it provides the
   theme (`ThemeData` and `ColorScheme`), the title, the `home` screen, and the
   navigator and messenger that widgets such as `Scaffold`, `SnackBar`, and
   `Theme.of(context)` depend on. It is used as the root widget because almost every
   Material widget expects these things to exist above it in the tree, and putting them
   in one place gives the whole app a consistent theme and navigation.

4. A `StatelessWidget` has no mutable state: its output depends only on the values it
   was given, so it is built once per configuration. A `StatefulWidget` has a separate
   `State` object that can change over time, and calling `setState` rebuilds the widget.
   I use `StatelessWidget` for screens and components that only display data, such as
   `MyHomePage`, `InfoCard`, and `ItemCard` here, which is simpler and cheaper.
   `StatefulWidget` is necessary when the UI has to change in response to something
   while the app runs, such as the counter in the default Flutter sample, a text field,
   or a list that is loaded and updated.

5. `BuildContext` is a handle to the position of a widget in the widget tree. Flutter
   passes it to `build`, and it lets a widget look up things that belong to its
   ancestors. In my code, `Theme.of(context)` reads the theme set by `MaterialApp`,
   `MediaQuery.of(context)` reads the screen width so the grid uses two columns on narrow
   phones and three on wider screens, and `ScaffoldMessenger.of(context)` finds the nearest 
   messenger to show a `SnackBar`. Without the right context these lookups would fail, because they 
   work by walking up the tree from that widget's position.

6. Hot reload injects the changed source code into the running Dart VM and rebuilds the
   widget tree while keeping the app's state, so changes appear in under a second. Hot
   restart reloads the whole app from `main()` and resets the state. Hot reload cannot be
   relied on for changes that alter the structure of the program rather than just
   `build` output: changing a `const` constructor to a non-`const` one (I got "Const
   class cannot become non-const" when I turned `MyHomePage` into a `StatelessWidget`),
   adding or removing fields, changing the type of a widget, editing `main()`, or
   initial values of state. Those need a hot restart (`R`), and changes to native code,
   assets declared in `pubspec.yaml`, or dependencies need a full restart.

### Assignment 8

1. `Navigator.push()` adds a new route on top of the stack, so the current screen stays
   underneath and the Back button returns to it. `Navigator.pushReplacement()` replaces
   the route that is on top with the new one, so the replaced screen cannot be returned
   to. `Navigator.pop()` removes the route on top and shows the one below it. The Add
   Achievement action card uses `Navigator.push()`, so the system Back button returns
   to the home screen. The drawer options use `pushReplacement()`: the Home option
   replaces the form with `MyHomePage()`, which takes the user back to the home screen
   (the stack then holds two home routes, because the form was opened on top of the
   first one, so Back from there shows the earlier home screen).

2. Every screen is a `Scaffold` with an `AppBar` and `drawer: const LeftDrawer()`. The
   `Scaffold` defines the page structure, the `AppBar` shows the title and the drawer
   icon automatically, and the `Drawer` is one reusable widget, so the home screen and
   both forms have the same navigation and only one place to change. The portfolio
   colour is shared: `Colors.indigo` is the `AppBar` and Save button colour on the Add
   Project and Add Achievement forms and the `DrawerHeader` colour, and the home
   screen's `AppBar` uses `colorScheme.primary`, which comes from the same indigo seed
   colour in `MaterialApp`.

3. The form is a `Form` inside a `SingleChildScrollView`, with a `Column` of fields and
   a full width Save button. Each field is wrapped in `Padding` so the fields are not
   stuck to each other or to the screen edge, and a `SizedBox(width: double.infinity)`
   makes the button as wide as the screen. The `SingleChildScrollView` is what handles
   limited space: when the screen is narrow or the keyboard covers part of it, the
   content scrolls instead of overflowing, so every field and the Save button stay
   reachable. I also added extra padding at the bottom so Save can be scrolled above
   the SnackBar that the action card shows when it opens the form.

4. `GlobalKey<FormState>` is the handle to the form's state: it lets the Save button
   reach the `Form` from outside the fields. Each `validator` is a function that
   returns an error message for an invalid value or `null` for a valid one. Pressing
   Save calls `_formKey.currentState!.validate()`, which runs every validator, shows
   the messages next to the fields that failed, and returns `true` only when all of
   them returned `null`. Only then does the dialog open. For example, the form rejects
   the year `3000` (the model only allows 1900 to 2100), a title of only spaces, and a
   title such as `<b>Winner</b>`. Choosing an input widget or keyboard type is not
   enough: the number keyboard and `digitsOnly` only stop letters from being typed, but
   `3000` is made of digits and still gets through, they do not apply to pasted or
   programmatic input on every platform, and they cannot express rules such as
   "required", "not only spaces", the maximum length, or the allowed range. Those rules
   have to be checked by the validator.

## AI Usage Disclosure

I used Claude Code (inside the Claude desktop app) for Tutorial 08 and Assignment 7.
It acted mostly as a tutor: it read the tutorial and assignment pages, gave me a step by
step plan, explained each concept (widget tree, `StatelessWidget`, `build`, `const`,
hot reload and hot restart, `SnackBar`), and told me what to type and where. I entered
the code into my own project and ran it myself in Chrome. After each step I asked it to
check my files, and it ran `flutter analyze` and `flutter test` on them and told me
what was wrong. For the final version of Assignment 7 I also asked it to follow the
grading rubric and and I reviewed and adjusted them.

Limitations and fixes I noticed: the tutorial's own layout overflows when there are more
than three menu cards (Claude Code measured an overflow of 276 pixels on a wide Chrome
window), so I wrapped the body in a `SingleChildScrollView` and changed the grid's
scroll settings and aspect ratio; the default counter test broke after I removed the
counter and had to be rewritten; I got "Const class cannot become non-const" on hot
reload and fixed it with a hot restart; my first push failed with "Repository not
found" because I had not created the GitHub repository yet; and the tutorial section
about installing the standalone Dart SDK with Homebrew was not needed because the
Flutter SDK already includes Dart. Claude Code's own shell did not have Flutter on its
`PATH`, so it ran Flutter by its full path instead.

For Assignment 8 I used Claude Code again, this time to write a step by step guide for
the assignment. It read the assignment page, chose the Achievements section, and wrote
and tested a reference implementation in a copy of my project (`flutter analyze`,
`flutter test`, and a web build checked in Chrome) before giving me the steps. I
followed the guide and entered the code in my own project (the new
`achievement_form.dart`, the new action card and drawer option, the tests, and the
README answers), ran it in Chrome, and committed each step myself on an
`assignment-8` branch.

Limitations and fixes I noticed: while testing, Claude Code found that the SnackBar of
the action card stays on screen for about four seconds after the form opens and covers
the bottom of the form, so I added bottom padding to the scrolling area so Save can be
scrolled above it; a first version of one test failed only because the hint text of the
title field was identical to the sample title I typed, not because of a bug in the
form; and Flutter's test font is much wider than the real one, so some overflow
warnings appear only in tests, which is why I verified the layout in Chrome as well.