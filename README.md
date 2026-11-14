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