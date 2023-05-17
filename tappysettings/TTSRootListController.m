#import <Foundation/Foundation.h>
#import "TTSRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation TTSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load custom format from user defaults
    NSString *customFormat = [[NSUserDefaults standardUserDefaults] objectForKey:@"customFormat"];
    
    // Use custom format to create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:customFormat];
    
    // Use date formatter to format current date
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    // Log formatted date to console
    NSLog(@"Formatted date: %@", dateString);
}


@end


@implementation MyRootListController

- (NSArray *)specifiers {

    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        
        for (PSSpecifier *specifier in _specifiers) {
            if ([specifier.identifier isEqualToString:@"isCustomDateEnabled"]) {
                if ([self readPreferenceValue:specifier]) {
                    PSSpecifier *customFormatSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Custom Format" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                    _customFormatIndexPath = [self indexPathForSpecifier:specifier];
                    [self insertSpecifier:customFormatSpecifier atIndex:_customFormatIndexPath.row + 1 animated:YES];
                }
            }
        }
    }
    
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    
    if ([specifier.identifier isEqualToString:@"isCustomDateEnabled"]) {
        BOOL isCustomDateEnabled = [value boolValue];
        if (isCustomDateEnabled) {
            if (!_customFormatIndexPath) {
                PSSpecifier *customFormatSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Custom Format" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
				_customFormatIndexPath = [NSIndexPath indexPathForRow:[self indexOfSpecifier:specifier] + 1 inSection:0];
                [self insertSpecifier:customFormatSpecifier atIndex:_customFormatIndexPath.row animated:YES];
            }
        } else {
            if (_customFormatIndexPath) {
                [self removeSpecifierAtIndex:_customFormatIndexPath.row animated:YES];
                _customFormatIndexPath = nil;
            }
        }
    }
}


@end


