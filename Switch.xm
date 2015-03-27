#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <libactivator/LAActivator.h>
#import <dlfcn.h>
#import <objc/runtime.h>

@interface ScreenshotFSSwitch : NSObject <FSSwitchDataSource>
@end

@interface SBScreenShotter : NSObject
+ (SBScreenShotter *)sharedInstance;
- (BOOL)_isWritingSnapshot; // iOS 8
- (BOOL)writingScreenshot; // iOS 6 - 7
- (void)saveScreenshot:(BOOL)save;
@end

@interface SBControlCenterController : NSObject
+ (SBControlCenterController *)sharedInstanceIfExists;
- (BOOL)isVisible;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completionBlock;
@end

@interface SBUIController : NSObject
+ (SBUIController *)sharedInstanceIfExists;
- (BOOL)isAppSwitcherShowing;
- (void)dismissSwitcherAnimated:(BOOL)animated;
@end

@implementation ScreenshotFSSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return FSSwitchStateOn;
}

- (void)takeScreenshot
{
	SBScreenShotter *shot = (SBScreenShotter *)[objc_getClass("SBScreenShotter") sharedInstance];
	if (shot) {
		BOOL writing = [shot respondsToSelector:@selector(writingScreenshot)] ? [shot writingScreenshot] : [shot _isWritingSnapshot];
		if (!writing)
			[shot saveScreenshot:YES];
	}
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
	if (kCFCoreFoundationVersionNumber > 793.00) {
		SBControlCenterController *controller = (SBControlCenterController *)[%c(SBControlCenterController) sharedInstanceIfExists];
		SBUIController *ui = (SBUIController *)[%c(SBUIController) sharedInstanceIfExists];
		if (controller && [controller isVisible]) {
			[controller dismissAnimated:YES completion:^{
				[self takeScreenshot];
			}];
		}
		if (ui && [ui isAppSwitcherShowing]) {
			[UIView animateWithDuration:0.0f delay:0.0 options:0 animations:^{
				[ui dismissSwitcherAnimated:YES];
			} completion:^(BOOL completed) {
				if (completed)
					[self takeScreenshot];
			}];
		}
		else
			[self takeScreenshot];
	} else
		[self takeScreenshot];
}

@end
