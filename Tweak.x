
#import <UIKit/UIKit.h>
#import "rootless.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>
 

@interface SBUILegibilityLabel : UIView
@property (nonatomic,copy) NSString *string;
@property (nonatomic,retain) UIFont *font;
-(void)setNumberOfLines:(long long)arg1;
-(void)setString:(NSString *)arg1;
-(void)setFrame:(CGRect)arg1;
@end

static NSString *dateStringFormat;

//// @interface _UIStatusBarStringView
@interface _UIStatusBarStringView : UIView
@property (nonatomic,copy) NSString * originalText;     
@property (nonatomic, strong) NSString *customFormat;
@property (nonatomic, strong) NSString *customFormat2Taps;
-(void)_setText:(id)arg1 ;
-(void)handleTapGesture;
- (void)handleTapUserFormat;        
@end

@interface _UIStatusBarTimeItem 
@end


// Create a custom gesture recognizer subclass for recognizing touches on main hook
@interface CustomTapGestureRecognizer : UITapGestureRecognizer
@end


// CustomTapGestureRecognizer implementation
@implementation CustomTapGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //self.state = UIGestureRecognizerStateRecognized;
}

@end


#define tappySettings ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.b4db1r3.tappy.plist") // defining my preferences location on the device

static BOOL tweakEnabled = YES; // Default value
static BOOL isCustomDateEnabled = NO; 
static BOOL isCustomDate2Enabled = NO; 
static float  animationDuration;
static NSString *customFormat;
static NSString *customFormat2Taps;



%hook _UIStatusBarStringView

-(void)didMoveToWindow
 {


%orig;

       
if ([self.originalText containsString:@":"]) {

	    self.userInteractionEnabled = YES;

        // Add a tap gesture recognizer to the view
// Create a gesture recognizer for 1 tap
UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
singleTapGesture.numberOfTapsRequired = 1;
[self addGestureRecognizer:singleTapGesture];

// Create a gesture recognizer for 2 taps
UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
doubleTapGesture.numberOfTapsRequired = 2;
[self addGestureRecognizer:doubleTapGesture];

// Set the single tap gesture to require the double tap gesture to fail
[singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    }
}



%new
 - (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {   
 

NSString *originalText = self.originalText;


NSInteger animationDurationV = animationDuration;

NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
[dateFormatter2 setDateFormat:customFormat];
NSDate *date = [NSDate date];
NSString *dateString2 = [dateFormatter2 stringFromDate:date];


if (tweakEnabled && isCustomDateEnabled) {
    [UIView transitionWithView:self
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self _setText:dateString2];
                    } completion:^(BOOL finished) {
                        [UIView transitionWithView:self
                                          duration:animationDurationV
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            [self _setText:originalText];
                                        } completion:nil];
                    }];
}
}


%new

 - (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
// Create a date formatter to format the date and time as a string
NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
[dateTimeFormatter setDateFormat:@"yyyy HH:mm"];
 

NSString *originalText = self.originalText;
NSInteger animationDurationV = animationDuration;


NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
[dateFormatter2 setDateFormat:customFormat2Taps];
NSDate *date = [NSDate date];
NSString *dateString2 = [dateFormatter2 stringFromDate:date];


if (tweakEnabled && isCustomDate2Enabled) {
    [UIView transitionWithView:self
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self _setText:dateString2];
                    } completion:^(BOOL finished) {
                        [UIView transitionWithView:self
                                          duration:animationDurationV
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            [self _setText:originalText];
                                        } completion:nil];
                    }];
}
}

%end


static NSString *const domain = @"com.b4db1r3.tappy";
static NSString *const preferencesNotification = @"com.b4db1r3.tappy/reloadPrefs";

@interface NSUserDefaults (SoundPalette)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

#define LISTEN_NOTIF(_call, _name) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)_call, CFSTR(_name), NULL, CFNotificationSuspensionBehaviorCoalesce);

// Prefs global variables

void loadPrefs() {
    // Fetch the NSUserDefaults for your tweak
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.b4db1r3.tappy"];
    if (prefs) {

        // Update global variables
        tweakEnabled = ([prefs objectForKey:@"tweakEnabled"]  ?    [[prefs objectForKey:@"tweakEnabled"] boolValue] : tweakEnabled );
        isCustomDateEnabled =    ([prefs objectForKey:@"isCustomDateEnabled"]     ?    [[prefs objectForKey:@"isCustomDateEnabled"] boolValue] : isCustomDateEnabled);
        customFormat = ([prefs objectForKey:@"customFormat"]     ?    [prefs objectForKey:@"customFormat"] : customFormat);
        animationDuration =    ([prefs objectForKey:@"animationDuration"]     ?    [[prefs objectForKey:@"animationDuration"] floatValue] : animationDuration );
        isCustomDate2Enabled =    ([prefs objectForKey:@"isCustomDate2Enabled"]     ?    [[prefs objectForKey:@"isCustomDate2Enabled"] boolValue] : isCustomDate2Enabled);
        customFormat2Taps = ([prefs objectForKey:@"customFormat2Taps"]     ?    [prefs objectForKey:@"customFormat2Taps"] : customFormat2Taps);
 

    }
}

%ctor {

     loadPrefs();
     LISTEN_NOTIF(loadPrefs, "com.b4db1r3.tappy/reloadPrefs")	
    
}







// static NSTimer *secondsTimer = nil;




// @interface _UILegibilityImageView : UIImageView
// @property (nonatomic,assign,readwrite,setter=is_setBlurRadius:) CGFloat is_blurRadius;
// @property (atomic,assign,readwrite) struct CGColor *contentsMultiplyColor;
// @property (atomic,assign,readwrite) struct  CGColor *backgroundColor;
// @property (atomic,assign,readwrite) struct  CGColor *borderColor;
// @property (atomic,assign,readwrite) struct  CGColor *shadowColor;
// - (void)updateColors;
// - (void)updateColor:(CADisplayLink *)displayLink;
// - (void)updateColor;
// - (void)updateColorForView:(UIView *)view withColor:(CGColorRef)color;
// - (void)updateSubviewsForView:(UIView *)view withColor:(CGColorRef)color;
// - (UIView *)findViewInSuperviewsOfClass:(Class)targetClass view:(UIView *)view;
// - (void)updateColor;
// @end


// @interface SBLockStateAggregator : NSObject {
//         unsigned long long _lockState;
// }
// +(id)sharedInstance;
// @end



// @interface CALayer (Magma)
// @property (assign) CGColorRef contentsMultiplyColor;
// @end



// %hook _UILegibilityImageView

// %new
// - (void)updateColorForView:(UIView *)view withColor:(CGColorRef)color {
//     if (view) {
//         view.layer.contentsMultiplyColor = color;
//     }
// }

// %new
// - (void)updateSubviewsForView:(UIView *)view withColor:(CGColorRef)color {
//     for (UIView *subview in view.subviews) {
//         if ([subview isKindOfClass:NSClassFromString(@"SBUILegibilityLabel")]) {

 
//             for (UIView *legibilitySubview in subview.subviews) {
//                 if ([legibilitySubview isKindOfClass:NSClassFromString(@"_UILegibilityView")]) {
//                     for (UIView *imageView in legibilitySubview.subviews) {
//                         if ([imageView isKindOfClass:NSClassFromString(@"_UILegibilityImageView")]) {
//                             [self updateColorForView:imageView withColor:color];






//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

// //NS

// %new
// - (UIView *)findViewInSuperviewsOfClass:(Class)targetClass view:(UIView *)view {
//     if (!view) {
//         return nil;
//     }
    
//     if ([view isKindOfClass:targetClass]) {
//         return view;
//     }
    
//     return [self findViewInSuperviewsOfClass:targetClass view:view.superview];
// }


// - (void)didMoveToWindow {
//     %orig;

//     UIView *dateView = [self findViewInSuperviewsOfClass:NSClassFromString(@"SBFLockScreenDateView") view:self];
//     if (dateView) {
//         dateView.backgroundColor = [UIColor blackColor];

 
//         // Since dateView is an instance of SBFLockScreenDateView, cast it to that type to avoid a compiler warning
 
//         // Get the _timeLabel instance variable
 
//         // Now you can call methods on timeLabel, e.g.:
 

 
//         [self updateSubviewsForView:dateView withColor:[UIColor purpleColor].CGColor];
//     }
// }




// %new
// - (void)updateColor {


//   [self didMoveToWindow];
// }


// %end



// @interface SBUILegibilityLabel : UIView 
// - (UIView *)findViewInSuperviewsOfClass:(Class)targetClass view:(UIView *)view;
// -(void)updateSeconds ;
// -(void)setString:(NSString *)arg1 ;
// -(float)expectedLabelWidth:(SBUILegibilityLabel *)label ;
// -(void)setNumberOfLines:(long long)arg1;
// -(NSString *)string;
// -(UIFont *)font;
// @property (copy,readonly) NSString * description; 
//  - (void)handleSingleTap:(UITapGestureRecognizer *)recognizer;
//  @property (nonatomic,copy) NSString * string;                                         //@synthesize string=_string - In the implementation block;
// @end

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
@end


// %hook SBUILegibilityLabel


 

// -(void)setString:(NSString *)arg1 {

//     %orig;
    

//         //UIView *dateView = [self findViewInSuperviewsOfClass:NSClassFromString(@"SBFLockScreenDateView") view:self];

// Ivar ivar = class_getInstanceVariable(objc_getClass("SBLockStateAggregator"), "_lockState");
// if (ivar) {
//     unsigned long long lockState = *(unsigned long long *)((__bridge void *)self + ivar_getOffset(ivar));
//     if (lockState != -1) {
//         if (secondsTimer == nil || ![secondsTimer isValid]) {
//             secondsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSeconds) userInfo:nil repeats:YES];



//         }
//         [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, [self expectedLabelWidth:self], self.frame.size.height)];
//     }
// }

// if (!ivar && secondsTimer != nil && [secondsTimer isValid]) {
//     [secondsTimer invalidate];
//     secondsTimer = nil;
// }

// }



// %new
// - (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
//     NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
//     [dateFormatter2 setDateFormat:@"dd/MM"]; // 24hr
//     NSString *currentDateString2 = [dateFormatter2 stringFromDate:[NSDate date]];
//     self.string = currentDateString2;
// }



// %new

// // calculate needed width
// -(float)expectedLabelWidth:(SBUILegibilityLabel *)label {
//     [label setNumberOfLines:1];
//     CGSize expectedLabelSize = [[label string] sizeWithAttributes:@{NSFontAttributeName:label.font}];
//     return expectedLabelSize.width + 2; // just added a tiny bit extra just in case otherwise sometimes it would just be ".."

// }

   
 



// %new
// -(void)updateSeconds 
// {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//     [dateFormatter setDateFormat:@"HH:mm:ss"]; // 24hr
//     NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
//     [self setString:currentDateString];
// }

// %new
// - (UIView *)findViewInSuperviewsOfClass:(Class)targetClass view:(UIView *)view {
//     if (!view) {
//         return nil;
//     }
    
//     if ([view isKindOfClass:targetClass]) {
//         return view;
//     }
    
//     return [self findViewInSuperviewsOfClass:targetClass view:view.superview];
// }

// %end


// %hook SBFLockScreenDateView

// -(void)setDateToTimeStretch:(double)arg1 {
// 	  %orig(0); // fixes the scroll lag
// 	//	debug("%f", arg1);
// }
// %end




// @interface SBFLockScreenDateView : UIView {
// 	SBUILegibilityLabel* _timeLabel;
// }
// -(float)expectedLabelWidth:(SBUILegibilityLabel *)label ;
// -(void)updateTimeLabel;
// -(void)handleTap:(UITapGestureRecognizer *)recognizer;
// @end


// %hook SBFLockScreenDateView

// -(void)layoutSubviews {
//      [self updateTimeLabel];
//     if (secondsTimer == nil && ![secondsTimer isValid]) {
//         secondsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
//     }
  


//       UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//       tapGesture.numberOfTapsRequired = 1;
//   [self setUserInteractionEnabled:YES];

//     [self addGestureRecognizer:tapGesture];


//     %orig;
// }

// %new
// -(void)handleTap:(UITapGestureRecognizer *)recognizer {
//     if (recognizer.state == UIGestureRecognizerStateEnded) {
//         Ivar labelViewIvar = class_getInstanceVariable([self class], "_timeLabel");
//         SBUILegibilityLabel *timeLabel = object_getIvar(self, labelViewIvar);

//         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//         [dateFormatter setDateFormat:@"dd/MM"];
//         NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
//         [timeLabel setString:currentDateString];

//         [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y, [self expectedLabelWidth:timeLabel], timeLabel.frame.size.height)];
//     }
// }

// %new
// // calculate needed width
// -(float)expectedLabelWidth:(SBUILegibilityLabel *)label {
//     [label setNumberOfLines:1];
//     CGSize expectedLabelSize = [[label string] sizeWithAttributes:@{NSFontAttributeName:label.font}];
//     return expectedLabelSize.width + 2; // just added a tiny bit extra just in case otherwise sometimes it would just be ".."

// }



// %new
// -(void)updateTimeLabel
// {
// Ivar lockStateIvar = class_getInstanceVariable(objc_getClass("SBLockStateAggregator"), "_lockState");

// unsigned long long lockState = *(unsigned long long *)((__bridge void *)self + ivar_getOffset(lockStateIvar));


//    if (!(lockState == 3)  && secondsTimer != nil && [secondsTimer isValid]) {
// 		        [secondsTimer invalidate];
// 		        secondsTimer = nil;
// 	}


//     Ivar labelViewIvar = class_getInstanceVariable([self class], "_timeLabel");
//     SBUILegibilityLabel *timeLabel = object_getIvar(self, labelViewIvar);


// 		    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
// [dateFormatter setDateFormat:@"HH:mm:ss"];
//         NSString *currentTimeString = [dateFormatter stringFromDate:[NSDate date]];
//         [timeLabel setString:currentTimeString];
// 			  [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, timeLabel.frame.origin.y, [self expectedLabelWidth:timeLabel], timeLabel.frame.size.height)];

// }
// %end