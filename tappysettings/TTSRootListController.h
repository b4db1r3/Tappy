#import <Preferences/PSListController.h>

@interface TTSRootListController : PSListController
@property (nonatomic, strong) NSString *customFormat;

@end


@interface MyRootListController : PSListController
{
    // ...
    NSIndexPath *_customFormatIndexPath;
}
@end


