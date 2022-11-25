// erkanyildiz
// 20221125-1857+0900
//
// EYLogTextView.h
//
// https://github.com/erkanyildiz/EYLogTextView

#import <UIKit/UIKit.h>

@interface EYLogTextView: UITextView

/**
 * Creates a shared EYLogTextView instance to capture logs and invisibly adds it to the key window once it is available.
 * Either shake the device or call @c show method to make it visible.
 */
+ (void)add;

/**
 * Shows the shared EYLogTextView instance with animation, if it is hidden.
 */
+ (void)show;

/**
 * Hides the shared EYLogTextView instance with animation, if it is visible.
 */
+ (void)hide;

/**
 * Toggles the shared EYLogTextView instance visibility with animation.
 */
+ (void)toggle;

/**
 * Clears the text on the shared EYLogTextView instance.
 */
+ (void)clear;

/**
 * Returns the shared EYLogTextView instance.
 * You can customize size, position, color and font as it is a UITextView subclass.
 */
+ (instancetype)sharedInstance;

@end
