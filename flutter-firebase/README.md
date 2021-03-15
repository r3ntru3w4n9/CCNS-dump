# Flutter Todo List with FireBase

## Link to this repository: [GitHub - b06901038/computer-security-hw5: https://dribbble.com/shots/3812962-iPhone-X-Todo-Concept Made With Flutter](https://github.com/b06901038/computer-security-hw5)

## This is a fork of: [GitHub - MarcL01/FlutterTodo: https://dribbble.com/shots/3812962-iPhone-X-Todo-Concept Made With Flutter](https://github.com/MarcL01/FlutterTodo)

### You said... you forked?

Yeah, forking on GitHub is surprisingly easy, requiring only one single click and you're done. I also renamed the project to my liking.

### What are the frameworks that you used in this project?

Since the project is forked from FlutterTodo, it uses, well, [Flutter](https://flutter.dev/) as its main framework. Flutter has the distince advantage of write once, run everywhere, which ironically is not the advantage of Java as java apps don't run on IOS and no longer Web. Flutter allows you to use only one codebase and transpiles into platform specific code and for now supports IOS and Android in production mode, Web in beta mode. In this project, I used Flutter beta and compiled it into a web app.

Also what I've used in the project is [Firebase](https://firebase.google.com/) with the aid of [FlutterFire](https://firebase.flutter.dev/). Firebase is known for its realtime sync-enabled database, now known as Firebase Realtime Database. For some reason Firebase offers two closely related but distinct API for nearly exact the same purpose, Realtime Database, which charges you the bandwidth it uses, and Cloud FIrestore, which charges for the amount of _CRUD_ actions used. At the moment where this `README.md` is written, only Cloud Firestore is available for Web applications, so this projects uses that.

### How do I run the project?

Make sure that Flutter is installed

```bash
# Running checks to see that you're ready to go
flutter doctor

# Switch to beta channel as stable does not yet support web apps
flutter channel beta

# Update the dependencies
flutter pub get

# Build for web apps
flutter build web
```

The resulting webpage and its bundle will be in `./web`

### The Good

Flutter is really fun to play with, notably, its hot reload feature allows quick edits to the code, without restarting the whole emulator and re-compiling all over again. Dart is a really nice language to write in, with its intuitive syntax and fun `async` capabilities. (It is slightly different to other language’s `async/await` such as Python or Rust in that an `async` function in Dart starts automatically, like starting a thread as opposed to needing to `await`.) Firebase overall offers a smooth experience as I followed FlutterFire’s instructions, although some API’s are very JavaScript style, which can’t be good, right? Folks?

### The Bad

As I said above, I hate JavaScript, and anything related to it has to be bad. In writing the app once I accidentally opened two `MaterialApp`'s, and it’s illegal to do so in Flutter. However, doing so in Dart is legal as those structures are runtime structures and I was not able to catch it during compiling. The result? I spent 3-4 hours for this bug alone because of how Flutter Web works, transpiling the Dart code into JavaScript and HTML and those web thingy language, and errors happen there. What happened was that I had to guess from the Chrome’s debug console’s output (Dart’s transpiling was actually pretty good, and I was able to read its JS transpilation without knowing a line of JavaScript), and look for the error. Which is not fun. Aside from that, the experience is painless 

### And the Ugly

Well, Flutter is beautiful, end of story.

### Screenshots

![Screenshot%20from%202020-12-09%2011-00-48](assets/Screenshot%20from%202020-12-09%2011-00-48.png)

![Screenshot%20from%202020-12-09%2011-01-37](assets/Screenshot%20from%202020-12-09%2011-01-37.png)

![Screenshot%20from%202020-12-09%2011-01-39](assets/Screenshot%20from%202020-12-09%2011-01-39.png)

![Screenshot%20from%202020-12-09%2011-01-44](assets/Screenshot%20from%202020-12-09%2011-01-44.png)

![Screenshot%20from%202020-12-09%2011-01-56](assets/Screenshot%20from%202020-12-09%2011-01-56.png)

![Screenshot%20from%202020-12-09%2011-02-07](assets/Screenshot%20from%202020-12-09%2011-02-07.png)

![Screenshot%20from%202020-12-09%2011-02-16](assets/Screenshot%20from%202020-12-09%2011-02-16.png)

![Screenshot%20from%202020-12-09%2011-02-58](assets/Screenshot%20from%202020-12-09%2011-02-58.png)
