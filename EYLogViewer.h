// erkanyildiz
// 20160925-0324JST
//
// https://github.com/erkanyildiz/EYLogViewer
//
// EYLogViewer.h

#import <Foundation/Foundation.h>

#ifdef NSLog
    #undef NSLog
#endif
#define NSLog(...) EYLog(__VA_ARGS__)
void EYLog(NSString *format, ...);


@interface EYLogViewer : NSObject
/**
 * Adds EYLogViewer to the top window of the application.
 *
 * Please call this method at the start of main.m to catch all logs.
 */
+ (void)add;

/**
 * Shows EYLogViewer with animation, if it is hidden.
 *
 * Three-finger swipe up gesture shows EYLogViewer also.
 */
+ (void)show;

/**
 * Hides EYLogViewer with animation, if it is visible.
 *
 * Three-finger swipe down gesture hides EYLogViewer also.
 */
+ (void)hide;

@end
