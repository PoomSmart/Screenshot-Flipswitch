#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>
#import <libactivator/LAActivator.h>
#import <dlfcn.h>
#import <objc/runtime.h>

@interface ScreenshotFSSwitch : NSObject <FSSwitchDataSource>
@end

@interface SBScreenShotter : NSObject
+ (SBScreenShotter *)sharedInstance;
- (BOOL)_isWritingSnapshot; // iOS 8+
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
- (void)dismissSwitcherAnimated:(BOOL)animated; // iOS 7+
@end

@interface SBMainSwitcherViewController : UIViewController
+ (SBMainSwitcherViewController *)sharedInstance;
- (void)dismissSwitcherNoninteractively;
@end

@implementation ScreenshotFSSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return FSSwitchStateOff;
}

- (void)reallyTakeScreenshot
{
	SBScreenShotter *shot = (SBScreenShotter *)[objc_getClass("SBScreenShotter") sharedInstance];
	if (shot) {
		BOOL writing = [shot respondsToSelector:@selector(writingScreenshot)] ? [shot writingScreenshot] : [shot _isWritingSnapshot];
		if (!writing)
			[shot saveScreenshot:YES];
	}
}

- (BOOL)isAppSwitcherShowing
{
	SBUIController *ui = (SBUIController *)[%c(SBUIController) sharedInstanceIfExists];
	return [ui isAppSwitcherShowing];
}

- (BOOL)isControlCenterVisible
{
	SBControlCenterController *controller = (SBControlCenterController *)[%c(SBControlCenterController) sharedInstanceIfExists];
	return [controller isVisible];
}

- (void)dismissControlCenterWithCompletion:(void (^)())completion
{
	SBControlCenterController *controller = (SBControlCenterController *)[%c(SBControlCenterController) sharedInstanceIfExists];
	[controller dismissAnimated:YES completion:^{
		if (completion)
			completion();
	}];
}

- (void)dismissSwitcherWithCompletion:(void (^)())completion
{
	SBUIController *ui = (SBUIController *)[%c(SBUIController) sharedInstanceIfExists];
	[UIView animateWithDuration:0.0f delay:0.0 options:0 animations:^{
		if ([ui respondsToSelector:@selector(dismissSwitcherAnimated:)])
			[ui dismissSwitcherAnimated:YES];
		else
			[(SBMainSwitcherViewController *)[%c(SBMainSwitcherViewController) sharedInstance] dismissSwitcherNoninteractively];
	} completion:^(BOOL completed) {
		if (completed) {
			if (completion)
				completion();
		}
	}];
}

- (void)takeScreenshot
{
	if (kCFCoreFoundationVersionNumber > 793.00) {
		BOOL switcher = [self isAppSwitcherShowing];
		BOOL cc = [self isControlCenterVisible];
		if (cc && switcher) {
			[self dismissControlCenterWithCompletion:^{
				[self dismissSwitcherWithCompletion:^{
					[self reallyTakeScreenshot];
				}];
			}];
		}
		else if (cc && !switcher) {
			[self dismissControlCenterWithCompletion:^{
				[self reallyTakeScreenshot];
			}];
		}
		else if (!cc && switcher) {
			[self dismissSwitcherWithCompletion:^{
				[self reallyTakeScreenshot];
			}];
		}
		else
			[self reallyTakeScreenshot];
	} else
		[self reallyTakeScreenshot];
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
	[self takeScreenshot];
}

@end