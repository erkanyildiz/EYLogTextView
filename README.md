# EYLogViewer
A simple viewer to see logs on your iDevice when it is not connected to Xcode.

#Features

 - One line to integrate
 - Always on top (except system windows like keyboards, alertviews etc...)
 - Visible on both light and dark backgrounds with optimal opacity, colors and size
 - NSLog compatible (no special logging method needed)
 - Drag&Drop to any point on the screen by long press
 - Copy log contents by double tap
 - Hide by 3-finger swipe down anywhere on screen
 - Show by 3-finger swipe up anywhere on screen

#Usage
Import `EYLogViewer` in `Prefix.pch` file of your project :

`#import "EYLogViewer.h"`

Add following line to beginning of `main` function in `main.m` :

`[EYLogViewer add];`


#ScreenShots
![ss1](https://cloud.githubusercontent.com/assets/1222652/13434323/c2bc7be8-e018-11e5-8578-c265730912ad.png)
![ss2](https://cloud.githubusercontent.com/assets/1222652/13434325/c2db4834-e018-11e5-9727-bc1747d114c5.png)
![ss3](https://cloud.githubusercontent.com/assets/1222652/13434326/c2f42da4-e018-11e5-857c-e995a8686bbb.png)
![ss4](https://cloud.githubusercontent.com/assets/1222652/13434327/c2f4eb36-e018-11e5-8e35-9bacfad52bc7.png)
