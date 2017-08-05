#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>
#import "Header.h"

@interface ScreenshotFSSwitch : NSObject <FSSwitchDataSource>
@end

@implementation ScreenshotFSSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return FSSwitchStateOff;
}

- (void)reallyTakeScreenshot {
    if (isiOS92Up)
        [UIApplication.sharedApplication.screenshotManager saveScreenshotsWithCompletion:nil];
    else {
        SBScreenShotter *shot = [NSClassFromString(@"SBScreenShotter") sharedInstance];
        if (shot) {
            BOOL writing = [shot respondsToSelector:@selector(writingScreenshot)] ? [shot writingScreenshot] : [shot _isWritingSnapshot];
            if (!writing)
                [shot saveScreenshot:YES];
        }
    }
}

- (BOOL)isAppSwitcherShowing {
    return [[NSClassFromString(@"SBUIController") sharedInstanceIfExists] isAppSwitcherShowing];
}

- (BOOL)isControlCenterVisible {
    return [[NSClassFromString(@"SBControlCenterController") sharedInstanceIfExists] isVisible];
}

- (void)dismissControlCenterWithCompletion:(void (^)())completion {
    [[NSClassFromString(@"SBControlCenterController") sharedInstanceIfExists] dismissAnimated:YES completion:^{
        if (completion)
            completion();
    }];
}

- (void)dismissSwitcherWithCompletion:(void (^)())completion {
    SBUIController *ui = [NSClassFromString(@"SBUIController") sharedInstanceIfExists];
    [UIView animateWithDuration:0.0f delay:0.0 options:0 animations:^{
        if ([ui respondsToSelector:@selector(dismissSwitcherAnimated:)])
            [ui dismissSwitcherAnimated:YES];
        else
            [[NSClassFromString(@"SBMainSwitcherViewController") sharedInstance] dismissSwitcherNoninteractively];
    } completion:^(BOOL completed) {
        if (completed) {
            if (completion)
                completion();
        }
    }];
}

- (void)takeScreenshot {
    if (isiOS7Up) {
        BOOL switcher = [self isAppSwitcherShowing];
        BOOL cc = [self isControlCenterVisible];
        if (cc && switcher) {
            [self dismissControlCenterWithCompletion:^{
                [self dismissSwitcherWithCompletion:^{
                    [self reallyTakeScreenshot];
                }];
            }];
        } else if (cc && !switcher) {
            [self dismissControlCenterWithCompletion:^{
                [self reallyTakeScreenshot];
            }];
        } else if (!cc && switcher) {
            [self dismissSwitcherWithCompletion:^{
                [self reallyTakeScreenshot];
            }];
        } else
            [self reallyTakeScreenshot];
    } else
        [self reallyTakeScreenshot];
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    [self takeScreenshot];
}

@end
