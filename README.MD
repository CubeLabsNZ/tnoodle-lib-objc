# DEPRECATED: USE [tnoodle-lib-native](https://github.com/CubeStuffs/tnoodle-lib-native) INSTEAD


# tnoodle-lib-objc

Script to transpile WCA'S tnoodle-lib to Objective-C using J2ObjC. iOS and MacOS releases are provided.

It is important to note that this script was written to use as a part of our parent project. If you would like to see a working example, please refer to [CubeTime](https://github.com/CubeStuffs/CubeTime), where you can see how we have bridged, imported and used tnoodle.

## How-To (prebuilt):
 - Download the static library (libtnoodle-macos.a or libtnoodle-ios.a) and the headers.tar.gz from the releases section
 - Download [J2ObjC](https://github.com/google/j2objc) (just .zip, not frameworks).
 - Extract J2ObjC and headers.tar.gz.
 - Go to "Search Paths" section in XCode under target > Build Settings
   - Under "Header Search Paths":
     - Add the path you extracted headers.tar.gz to
     - Add the path you extracted J2ObjC to, + /include
   - Under "Library Search Paths":
     - Add the path you downloaded libtnoodle.a to
     - Add the path you extracted J2ObjC to, + /lib (or /lib/macosx, /lib/maccatalyst, /lib/watchos, /lib/appletvos) (note that I have not tested TNoodle on these platforms)
 - Go to "Linking" Section > "Other Linker Flags" and add:
   - -ltnoodle (rename libtnoodle_macos.a or libtnoodle_ios.a just to libtnoodle.a, or set this flag to -ltnoodle_macos or -ltnoodle_ios)
   - -ljre_core
   - -ljre_security
   - -ljre_net
   - -ljre_util
 - Go to "General" tab:
    - Under "Frameworks, Libraries and Embedded Content" add:
      - libiconv.tbd
      - Security.framework

 - Compile and hope for the best!

## How-To (transpile and compile yourself):
 - Clone this repo (downloading "source code" from releases will not include tnoodle-lib submodule)
 - Ensure you have XCode installed, with the iOS and MacOS SDKs
 - Run ./build.sh, but first take note of these supported env vars:
   - JAVA_HOME - set this to the root of your Java install. Only Java 1.8, 11 and 15 are supported by J2ObjC.
   - J2OBJC_DIR - set this to the directory where the J2ObjC distibution is contained (default: j2objc)
   - TNOODLE_DIR - set this to the path of tnoodle-lib (default: tnoodle-lib)
   - BUILD - set this to a folder where build output should be (default: build)
   - LIBTOOL - set this to your libtool binary (default: libtool)
   - LIPO - set this to your lipo binary (default: lipo)
   - OBJCFLAGS - set this to any flags you want to pass to jobjcc/clang (default: -Os)
   - TAR - set this to your tar binary (default: tar)
 - After the command finishes successfully, it will output headers.tar.gz, source.tar.gz, libtnoodle_macos.a and libtnoodle_ios.a in the build directory. Use these files as detailed in the above section.

## FAQ (not really no one has asked anything yet)
### Why not GitHub actions?
tnoodle-lib seems to be updated infrequently. If this frequency increases, I will write a GitHub action.
### Why not Makefile?
I tried with a makefile but decided not to fight it. If you want to do the brave job of converting to make, I will gladly accept a pull request!
### License?
MIT, but beware that J2ObjC and TNoodle-lib are licensed Apache 2.0 and GPL 3.0 respectively
### How do I use TNoodle once included?
If you are using swift, you'll need a [bridging header](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift).

In your Objective-C code or Swift bridging header, `#import` `"org/worldcubeassociation/tnoodle/scrambles/PuzzleRegistry.h"` and `"org/worldcubeassociation/tnoodle/scrambles/Puzzle.h"`.

You can then call `OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry_get_\[Puzzle constant]()` from there.

See [tnoodle-lib wiki](https://github.com/thewca/tnoodle-lib/wiki/Using-TNoodle-lib-in-your-application) and [tnoodle-lib puzzle registry source code](https://github.com/thewca/tnoodle-lib/blob/master/scrambles/src/main/java/org/worldcubeassociation/tnoodle/scrambles/PuzzleRegistry.java).
