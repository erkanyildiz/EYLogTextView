// erkanyildiz
// 20221125-1857+0900
//
// EYLogTextView.m
//
// https://github.com/erkanyildiz/EYLogTextView

#import "EYLogTextView.h"
#import <objc/runtime.h>


#pragma mark - UIResponder swizzle for detecting device shake

@implementation UIResponder (EYLogTextView)

+ (void)setupShakeMotionDetection
{
    // NOTE: Swizzle motionEnded:withEvent: method to enable toogling visibility on device shake
    Method originalMethod = class_getInstanceMethod(self.class, @selector(motionEnded:withEvent:));
    Method swizzledMethod = class_getInstanceMethod(self.class, @selector(EYLogTextView_motionEnded:withEvent:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


- (void)EYLogTextView_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self EYLogTextView_motionEnded:motion withEvent:event];

//    [EYLogTextView toggle];
}

@end




#pragma mark - UIViewController category for detecting top view controller

@implementation UIViewController (EYLogTextView)

+ (UIWindow *)keyWindow
{
    // NOTE: `keyWindow` property of `UIApplication.sharedApplication` is deprecated. That is why we have this instead.
    for (UIWindowScene* scene in UIApplication.sharedApplication.connectedScenes)
        for (UIWindow* window in scene.windows)
            if (window.isKeyWindow)
                return window;

    return nil;
}


+ (UIViewController *)top
{
    UIViewController* topVC = self.keyWindow.rootViewController;

    while (topVC.presentedViewController)
        topVC = topVC.presentedViewController;

    return topVC;
}

@end




#pragma mark - UIAlertController category for adding actions conveniently

@implementation UIAlertController (EYLogTextView)

+ (UIAlertController *)actionSheetWithTitle:(NSString *)title
{
    // NOTE: To make title appear with larger padding.
    NSString* titleWithNewLine = [@"\n" stringByAppendingString:title];

    // NOTE: UIAlertControllerStyleActionSheet is not available on iPad and causes crash.
    UIAlertControllerStyle style = UIAlertControllerStyleAlert;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        style = UIAlertControllerStyleActionSheet;

    return [UIAlertController alertControllerWithTitle:titleWithNewLine message:nil preferredStyle:style];
}


- (void)addActionWithTitle:(NSString *)title handler:(void (^)(void))handler
{
    [self addActionWithTitle:title isDestructive:NO isCancel:NO handler:handler];
}


- (void)addDestructiveActionWithTitle:(NSString *)title handler:(void (^)(void))handler
{
    [self addActionWithTitle:title isDestructive:YES isCancel:NO handler:handler];
}


- (void)addCancelActionWithHandler:(void (^)(void))handler
{
    [self addActionWithTitle:@"Cancel" isDestructive:NO isCancel:YES handler:handler];
}


- (void)addActionWithTitle:(NSString *)title isDestructive:(BOOL)isDestructive isCancel:(BOOL)isCancel handler:(void (^)(void))handler
{
    UIAlertActionStyle style = UIAlertActionStyleDefault;

    if (isDestructive)
        style = UIAlertActionStyleDestructive;

    if (isCancel)
        style = UIAlertActionStyleCancel;

    UIAlertAction* action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * action)
    {
        if (handler)
            handler();
    }];
    [self addAction:action];
}


- (void)present
{
    [UIViewController.top presentViewController:self animated:YES completion:nil];
}

@end




#pragma mark - EYLogTextView

@interface EYLogTextView ()
@property BOOL shouldStayOnTop;
@end


@implementation EYLogTextView

#pragma mark - Shared instance convenience methods

+ (instancetype)sharedInstance
{
    static EYLogTextView* s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s_sharedInstance = self.new; });
    return s_sharedInstance;
}


+ (void)add
{
    // NOTE: Just a shorthand to initialize the shared instance.
    [EYLogTextView sharedInstance];
}


+ (void)show
{
    [EYLogTextView.sharedInstance showWithAnimation];
}


+ (void)hide
{
    [EYLogTextView.sharedInstance hideWithAnimation];
}


+ (void)toggle
{
    [EYLogTextView.sharedInstance toggleWithAnimation];
}


+ (void)clear
{
    EYLogTextView.sharedInstance.text = @"";
}


#pragma mark - Force using shared instance

- (NSException *)exception
{
    return [NSException exceptionWithName:@"EYLogTextViewException" reason:@"Please use shared instance instead of creating your own!" userInfo:nil];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    [self.exception raise];

    return [super initWithFrame:frame];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    [self.exception raise];

    return [super initWithCoder:coder];
}


#pragma mark - Initialization

- (instancetype)init
{
    self = [super initWithFrame:self.defaultFrame];

    [self startCapturingLogs];

    NSLog(@"=== BEGINNING OF LOGS ===\n%@", [self logFileName]);

    [self stylize];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyWindowBecameAvailable:) name:UIWindowDidBecomeKeyNotification object:nil];

    [self setupGestureRecognizers];

    return self;
}


- (CGRect)defaultFrame
{
    CGFloat const heightRatio = 0.5;
    CGFloat const margin = 8.0;
    CGFloat width = UIScreen.mainScreen.bounds.size.width - 2.0 * margin;
    CGFloat height = UIScreen.mainScreen.bounds.size.height * heightRatio;
    CGFloat x = margin;
    CGFloat y = (UIScreen.mainScreen.bounds.size.height - height) * 0.5;
    return (CGRect){x, y, width, height};
}


- (void)startCapturingLogs
{
    // NOTE: Capture logs on both `stderr` and `stdout`
    NSPipe* pipe = NSPipe.pipe;
    NSFileHandle* fhr = pipe.fileHandleForReading;
    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stderr));
    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout));
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(readCompleted:) name:NSFileHandleReadCompletionNotification object:fhr];
    [fhr readInBackgroundAndNotify];
}


- (void)stylize
{
    self.alpha = 0.0; // NOTE: Initially invisible.
    self.backgroundColor = [UIColor colorWithRed:156/255.0 green:82/255.0 blue:72/255.0 alpha:1];
    self.textColor = [UIColor colorWithRed:215/255.0 green:201/255.0 blue:169/255.0 alpha:1.0];
    self.font = [UIFont fontWithName:@"Menlo" size:10.0];

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    self.editable = NO;
    self.selectable = NO;
    self.showsVerticalScrollIndicator = YES;

    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:92/255.0 green:44/255.0 blue:36/255.0 alpha:1].CGColor;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowOffset = (CGSize){0.0, 2.0};
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 1.0;
}


- (void)setupGestureRecognizers
{
    // NOTE: For showing/hiding console on device shake
//    [UIResponder setupShakeMotionDetection];

    // NOTE: For showing menu on single tap
    UITapGestureRecognizer* tapGestureRec = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTap:)];
    tapGestureRec.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRec];

    // NOTE: For drag&drop on long press
    UILongPressGestureRecognizer* longPressGestureRec = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(onLongPress:)];
    longPressGestureRec.minimumPressDuration = 0.2;
    [self addGestureRecognizer:longPressGestureRec];
}


- (void)keyWindowBecameAvailable:(NSNotification *)notification
{
    // NOTE: Key window is now available, EYLogTextView can add itself as a subview to it.
    //  Also can start observing sublayer changes to stay on top.
    UIWindow* window = notification.object;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [window addSubview:self];
        self.shouldStayOnTop = YES;
        [window.layer addObserver:self forKeyPath:@"sublayers" options:0 context:NULL];
    });
}


#pragma mark - Visibility

- (void)hideWithAnimation
{
    if (self.alpha == 0.0)
        return;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ self.alpha = 0.0; } completion:nil];
}


- (void)showWithAnimation
{
    if (self.alpha != 0.0)
        return;

    [self.superview bringSubviewToFront:self];

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{ self.alpha = 0.7; }completion:nil];
}


- (void)toggleWithAnimation
{
    if (self.alpha == 0.0)
        [self showWithAnimation];
    else
        [self hideWithAnimation];
}


// NOTE: While presenting action menu, logs list and share dialogs, disable staying on top temporarily.
- (void)temporarilyDisableStayingOnTop
{
    self.shouldStayOnTop = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        self.shouldStayOnTop = YES;
    });

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if (self.shouldStayOnTop)
        [self.superview bringSubviewToFront:self];
}


#pragma mark - Read / Write

- (void)readCompleted:(NSNotification *)notification
{
    [((NSFileHandle *)notification.object) readInBackgroundAndNotify];

    NSString* log = [NSString.alloc initWithData:notification.userInfo[NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];

    dispatch_async(dispatch_get_main_queue(), ^{ [self appendLog:log]; });

    [self writeToFile:log];
}


- (void)appendLog:(NSString *)log
{
    CGFloat maxContentOffsetY = self.contentSize.height - self.frame.size.height;
    BOOL shouldAutoScroll = (self.contentOffset.y >=  maxContentOffsetY - 1.0);

    self.text = [self.text stringByAppendingString:log];

    if (shouldAutoScroll)
    {
        [self scrollRangeToVisible:(NSRange){self.text.length - 1, 1}];
    }
}


- (void)writeToFile:(NSString *)log
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSURL* logFileURL = [self logFileURL];

        NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFileURL.path];
        if (!fileHandle)
        {
            [log writeToFile:logFileURL.path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
    });
}


- (NSURL *)logFileURL
{
    static NSURL* logFileURL = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSURL* applicationSupportDirectoryURL = [[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        if (![NSFileManager.defaultManager fileExistsAtPath:applicationSupportDirectoryURL.path])
            [NSFileManager.defaultManager createDirectoryAtURL:applicationSupportDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];

        logFileURL = [applicationSupportDirectoryURL URLByAppendingPathComponent:[self logFileName]];
    });

    return logFileURL;
}


- (NSString *)logFileName
{
    static NSString* fileName = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString* versionNumber = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString* buildNumber =  [NSBundle.mainBundle.infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];

        NSDateFormatter* df = NSDateFormatter.new;
        df.calendar = [NSCalendar.alloc initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        df.locale = [NSLocale.alloc initWithLocaleIdentifier:@"en_US"];
        df.dateFormat = @"yyyyMMdd_HHmmss";
        NSString* dateTime = [df stringFromDate:NSDate.date];

        fileName = [NSString stringWithFormat:@"%@_v%@_b%@_iOS%@_%@.log",
            NSBundle.mainBundle.bundleIdentifier,
            versionNumber,
            buildNumber,
            UIDevice.currentDevice.systemVersion,
            dateTime];
    });

    return fileName;
}


#pragma mark - User actions

- (void)onLongPress:(UILongPressGestureRecognizer *)recognizer
{
    UITextView* textView = (UITextView *)recognizer.view;
    static CGPoint diff;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint startPoint = [recognizer locationInView:textView.superview];
        diff = (CGPoint){textView.center.x - startPoint.x, textView.center.y - startPoint.y};
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint currentPoint = [recognizer locationInView:textView.superview];
        CGPoint adjustedPoint = (CGPoint){currentPoint.x + diff.x, currentPoint.y + diff.y};
        textView.center = adjustedPoint;
    }
}


- (void)onTap:(UITapGestureRecognizer *)recognizer
{
    UIAlertController* menuAlert = [UIAlertController actionSheetWithTitle:@"EYLogTextView menu"];

    [menuAlert addActionWithTitle:@"Share current log file" handler:^
    {
        NSURL* currentLogFileURL = [self logFileURL];
        if (!currentLogFileURL)
            return;

        [self shareItems:@[currentLogFileURL]];
    }];

    [menuAlert addActionWithTitle:@"See all log files" handler:^
    {
        [self seeAllLogFiles];
    }];

    [menuAlert addActionWithTitle:@"Share current console text" handler:^
    {
        [self shareItems:@[self.text]];
    }];

    [menuAlert addActionWithTitle:@"Hide" handler:^
    {
        [self hideWithAnimation];
    }];

    [menuAlert addDestructiveActionWithTitle:@"Clear current console text" handler:^
    {
        self.text = @"";
    }];

    [menuAlert addCancelActionWithHandler:nil];

    [self temporarilyDisableStayingOnTop];
    [menuAlert present];
}


- (void)seeAllLogFiles
{
    NSURL* applicationSupportDirectoryURL = [[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];

    NSMutableArray* logFiles = [NSFileManager.defaultManager contentsOfDirectoryAtPath:applicationSupportDirectoryURL.path error:nil].mutableCopy;

    // NOTE: Exclude files that are not logs.
    [logFiles filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings)
    {
        return [obj hasPrefix:NSBundle.mainBundle.bundleIdentifier] && [obj hasSuffix:@".log"];
    }]];

    [logFiles sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        return [obj2 compare:obj1];
    }];

    UIAlertController* listAlert = [UIAlertController actionSheetWithTitle:@"List of all log files"];

    for (NSString* logFile in logFiles)
    {
        [listAlert addActionWithTitle:logFile handler:^
        {
            NSURL* URL = [applicationSupportDirectoryURL URLByAppendingPathComponent:logFile];
            if (!URL)
                return;;

            [self shareItems:@[URL]];
        }];
    }

    [listAlert addDestructiveActionWithTitle:@"Delete All (except current)" handler:^
    {
        for (NSString* logFile in logFiles)
        {
            // NOTE: Do not delete the current log file
            if ([logFile isEqualToString:[self logFileName]])
                continue;

            NSURL* URL = [applicationSupportDirectoryURL URLByAppendingPathComponent:logFile];
            [NSFileManager.defaultManager removeItemAtPath:URL.path error:nil];
        }
    }];

    [listAlert addCancelActionWithHandler:nil];

    [self temporarilyDisableStayingOnTop];
    [listAlert present];
}


- (void)shareItems:(NSArray *)items
{
    UIActivityViewController* activityVC = [UIActivityViewController.alloc initWithActivityItems:items applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView = self;
    activityVC.popoverPresentationController.sourceRect = (CGRect){CGPointZero, 0.0, 0.0};
    [self temporarilyDisableStayingOnTop];
    [UIViewController.top presentViewController:activityVC animated:YES completion:nil];
}

@end
