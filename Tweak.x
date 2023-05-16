
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "rootless.h"


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

static BOOL tweakEnabled = NO; // Default value
static BOOL isCustomDateEnabled = NO; 
static BOOL isCustomDate2Enabled = NO; 
static float  animationDuration;
static NSString *customFormat;
static NSString *customFormat2Taps;



%hook _UIStatusBarStringView

-(void)didMoveToWindow {


%orig;


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

@interface NSUserDefaults (Tappy)
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