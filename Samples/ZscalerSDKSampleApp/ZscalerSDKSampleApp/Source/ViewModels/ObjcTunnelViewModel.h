#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import Zscaler;

NS_ASSUME_NONNULL_BEGIN

/// Handles control of the Zscaler tunnel and communicates state changes to the UI.
@interface TunnelViewModel : NSObject

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSUUID *deviceUuid;

- (void)startPreLogin;
- (void)startZeroTrust;
- (void)stopTunnel;

@end

NS_ASSUME_NONNULL_END
