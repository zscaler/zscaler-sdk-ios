#import "ObjcTunnelViewModel.h"
#import <os/log.h>

@import Zscaler;

// MARK: - TunnelViewModel Implementation

@interface TunnelViewModel()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation TunnelViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _appKey = @"";
        _accessToken = @"";
        _deviceUuid = [NSUUID UUID];
        _backgroundTask = UIBackgroundTaskInvalid;

        [self subscribeToNotifications];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)subscribeToNotifications {
    NSArray<NSNotificationName> *notificationNames = @[
        ZscalerSDKTunnelDisconnected, ZscalerSDKTunnelConnected, ZscalerSDKTunnelResourceBlocked,
        ZscalerSDKTunnelReconnecting, ZscalerSDKTunnelAuthenticationRequired
    ];

    for (NSNotificationName name in notificationNames) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleZscalerNotification:) name:name object:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// MARK: - Public Methods (Actions)

- (void)startPreLogin {
    os_log(OS_LOG_DEFAULT, "Starting Pre-Login Tunnel");
    [[ZscalerSDK sharedInstance] startPreLoginTunnelWithAppKey:self.appKey deviceUdid:self.deviceUuid.UUIDString completionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                os_log_error(OS_LOG_DEFAULT, "Error starting pre login tunnel: %{public}@", error);
            } else {
                os_log(OS_LOG_DEFAULT, "Started pre login tunnel");
            }
        });
    }];
}

- (void)startZeroTrust {
    os_log(OS_LOG_DEFAULT, "Starting Zero Trust Tunnel");
    [[ZscalerSDK sharedInstance] startZeroTrustTunnelWithAppKey:self.appKey deviceUdid:self.deviceUuid.UUIDString accessToken:self.accessToken completionHandler:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                os_log_error(OS_LOG_DEFAULT, "Error starting zero trust tunnel: %{public}@", error);
            } else {
                os_log(OS_LOG_DEFAULT, "Started zero trust tunnel");
            }
        });
    }];
}

- (void)stopTunnel {
    os_log(OS_LOG_DEFAULT, "Stopping Tunnel");
    [[ZscalerSDK sharedInstance] stopTunnelWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            os_log(OS_LOG_DEFAULT, "Stopped tunnel");
        });
    }];
}

// MARK: - Session Configuration

- (NSURLSession*)getConfiguredUrlSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    bool success = [[ZscalerSDK sharedInstance] setupWithSessionConfiguration:configuration];
    os_log(OS_LOG_DEFAULT, "Configure session successful: %d", success);
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (NSURLSession*)getConfiguredUrlSessionConfiguredManually {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    ZscalerSDKProxyInfo *proxyInfo = [[ZscalerSDK sharedInstance] proxyInfo];
    if (proxyInfo) {
        configuration.connectionProxyDictionary = @{
            @"HTTPSEnable": @1,
            @"HTTPSProxy": proxyInfo.proxyHost,
            @"HTTPSPort": @(proxyInfo.proxyPort),
        };
        
        if (proxyInfo.username && proxyInfo.password) {
            NSString *proxyToken = [[[NSString stringWithFormat:@"%@:%@", proxyInfo.username, proxyInfo.password]
                                     dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
            NSMutableDictionary *headers = [configuration.HTTPAdditionalHeaders mutableCopy];
            if (!headers) {
                headers = [[NSMutableDictionary alloc] init];
            }
            [headers setObject:[NSString stringWithFormat:@"Basic %@", proxyToken] forKey:@"Proxy-Authorization"];
            configuration.HTTPAdditionalHeaders =  headers;
        }
    }
    return [NSURLSession sessionWithConfiguration:configuration];
}



// MARK: - Background Task Handling

- (void)willEnterForeground {
    [self invalidateBackgroundTask];
    [[ZscalerSDK sharedInstance] resume];
}

- (void)didEnterBackground {
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        UIApplication *app = [UIApplication sharedApplication];
        self.backgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [[ZscalerSDK sharedInstance] suspend];
            [self invalidateBackgroundTask];
        }];
    }
}

- (void)invalidateBackgroundTask {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

// MARK: - Private Helpers

- (void)handleZscalerNotification:(NSNotification *)notification {
    NSDictionary *info = notification.object;
    NSString *notificationName = info[ZscalerSDKNotificationNameUserInfoKey] ?: @"???";
    NSString *notificationMessage = info[ZscalerSDKNotificationMessageUserInfoKey];

    os_log(OS_LOG_DEFAULT, "Got notification: %@ with message: %@", notificationName, notificationMessage);
}


- (NSString *)tunnelTypeToString:(ZscalerSDKTunnelType)tunnelType {
    if (tunnelType == ZscalerSDKTunnelTypePreLogin) {
        return @"PreLogin";
    } else if (tunnelType == ZscalerSDKTunnelTypeZeroTrust) {
        return @"ZeroTrust";
    } else {
        return @"Unknown";
    }
}

@end
