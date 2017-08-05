#import "../../PS.h"

@protocol _SBScreenshotProvider // iOS 9.2+
- (UIImage *)captureScreenshot;
@end

@interface _SBScreenshotPersistenceCoordinator : NSObject // iOS 9.2+
- (BOOL)isSaving;
- (BOOL)_isWritingSnapshot;
- (void)saveScreenshot:(UIImage *)image withCompletion:(void (^)())completionBlock;
@end

@interface SBScreenshotManager : NSObject // iOS 9.2+
- (NSObject <_SBScreenshotProvider> *)_providerForScreen:(UIScreen *)screen;
- (void)saveScreenshotsWithCompletion:(void (^)())completionBlock;
@end

@interface UIApplication (iOS92)
- (SBScreenshotManager *)screenshotManager;
@end

@interface SBScreenShotter : NSObject
+ (instancetype)sharedInstance;
- (BOOL)_isWritingSnapshot; // iOS 8+
- (BOOL)writingScreenshot; // iOS 6 - 7
- (void)saveScreenshot:(BOOL)save;
@end

@interface SBControlCenterController : NSObject
+ (instancetype)sharedInstanceIfExists;
- (BOOL)isVisible;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completionBlock;
@end

@interface SBUIController : NSObject
+ (instancetype)sharedInstanceIfExists;
- (BOOL)isAppSwitcherShowing;
- (void)dismissSwitcherAnimated:(BOOL)animated; // iOS 7+
@end

@interface SBMainSwitcherViewController : UIViewController
+ (instancetype)sharedInstance;
- (void)dismissSwitcherNoninteractively;
@end
