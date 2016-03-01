# EYLogViewer
A simple viewer to see logs on your iDevice when it is not connected to Xcode.

#Features

 - One line to integrate
 - Always on top (except keyboards etc...)
 - Visible on both light and dark backgrounds with optimal opacity, colors and size
 - NSLog compatible (no special logging method needed)
 - Drag&Drop to any point on the screen by long press
 - Copy log contents by double tap
 - Hide by 3-finger swipe down anywhere on screen
 - Show by 3-finger swipe up anywhere on screen

#Usage
Add following line:

`[EYLogViewer add];`

in `main.m` or `application:didFinishLaunchingWithOptions:` method of your application.

`main.m` is recommended to catch logs generated while app is being launhed.
And do not forget to import of course:

`#import "EYLogViewer.h"`
