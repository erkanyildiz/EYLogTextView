# EYLogViewer
A simple viewer to see your app's logs on your iDevice in realtime.

# Features

 - One line to integrate
 - Always on top (except system windows like keyboards, alertviews etc...)
 - Visible on both light and dark backgrounds with optimal opacity, colors and size (macOS Terminal.app `Red Sands` theme)
 - `NSLog` and `print` compatible (no special logging method needed)
 - Uses `NSPipe` on `stderr` and `stdout` (no overhead)
 - Works even while not connected to Xcode
 - Compatible with both `Objective-C` and `Swift` projects
 - Drag&Drop to any point on the screen by long press
 - Copy console logs by double tap
 - Clear console logs by triple tap
 - Hide by 3-finger swipe down anywhere on screen
 - Show by 3-finger swipe up anywhere on screen

# Usage

## Objective-C Projects

In your project's `main.m`, import `EYLogViewer.h` and add following line at the beginning of `main` function :

```
[EYLogViewer add];
```

## Swift Projects

In your project's `Bridging Header`, import `EYLogViewer.h` and add following line at the beginning of `application:didFinishLaunchingWithOptions` function :

```
EYLogViewer.add()
```

# ScreenShots
![ss1](https://cloud.githubusercontent.com/assets/1222652/13434323/c2bc7be8-e018-11e5-8578-c265730912ad.png)
![ss2](https://cloud.githubusercontent.com/assets/1222652/13434325/c2db4834-e018-11e5-9727-bc1747d114c5.png)
![ss3](https://cloud.githubusercontent.com/assets/1222652/13434326/c2f42da4-e018-11e5-857c-e995a8686bbb.png)
![ss4](https://cloud.githubusercontent.com/assets/1222652/13434327/c2f4eb36-e018-11e5-8e35-9bacfad52bc7.png)
