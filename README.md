# EYLogTextView
A simple UITextView subclass to see your app's logs on your iDevice in realtime.

# Features

 - One line to integrate. Singleton for easier access.
 - Shake device to hide and show.
 - Compatible with standard `NSLog`, `print` and `Logger`, no special logging method needed.
 - Saves all logs to local files to be shared later.
 - Customizable size, position, opacity, font and colors.
 - Default style is optimized for best visibility based on macOS Terminal.app `Red Sands` theme.
 - Always on top, except for system windows like keyboards, alerts, etc.
 - Uses `NSPipe` on `stderr` and `stdout` (no overhead).
 - Works even while not connected to Xcode.
 - Compatible with both `Objective-C` and `Swift` projects.
 - Drag&Drop to any point on the screen by long press.

# Integration

## Objective-C Projects

In your project's `AppDelegate`, import `EYLogTextView.h` and add following line at the beginning of `application:didFinishLaunchingWithOptions:` method:

```
[EYLogTextView add];
```

(For potentially capturing earlier logs you can start it `main.m` as well.)

## Swift Projects

In your project's `Bridging Header`, import `EYLogTextView.h` and add following line at the beginning of `application:didFinishLaunchingWithOptions:` function:

```
EYLogTextView.add()
```

# Usage

- By default `EYLogTextView` will be hidden. You can shake your device to make it visible.
- You can also use `show`/`hide` or `toggle` methods to change visibility.
- As it is a `UITextView` subclass singleton, you can customizable size, position, opacity, font and colors as you wish by accessing the shared instance using `sharedInstance` method.
- You can long press to drag&drop it anywhere you want.
- You can tap to display menu with following options:
    - Share current log file
    - See all log files
    - Share current console text
    - Hide
    - Clear current console text
- You can share all previously saved logs files and current log file.
- You can delete all previously saved logs files.

# ScreenShots (will be updated soon)
![ss1](https://cloud.githubusercontent.com/assets/1222652/13434323/c2bc7be8-e018-11e5-8578-c265730912ad.png)
![ss2](https://cloud.githubusercontent.com/assets/1222652/13434325/c2db4834-e018-11e5-9727-bc1747d114c5.png)
![ss3](https://cloud.githubusercontent.com/assets/1222652/13434326/c2f42da4-e018-11e5-857c-e995a8686bbb.png)
![ss4](https://cloud.githubusercontent.com/assets/1222652/13434327/c2f4eb36-e018-11e5-8e35-9bacfad52bc7.png)
