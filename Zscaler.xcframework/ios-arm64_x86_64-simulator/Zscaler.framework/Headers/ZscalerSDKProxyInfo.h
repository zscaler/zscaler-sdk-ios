
#import <Foundation/Foundation.h>
#import <Zscaler/ZscalerSDKAttributes.h>

NS_ASSUME_NONNULL_BEGIN

ZSDK_PUBLIC
@interface ZscalerSDKProxyInfo: NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHost:(NSString*)host
                        port:(NSInteger)port
                    username:(nullable NSString*)username
                    password:(nullable NSString*)password NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *proxyHost;
@property (nonatomic, readonly) NSInteger proxyPort;
@property (nonatomic, readonly, nullable) NSString* username;
@property (nonatomic, readonly, nullable) NSString* password;

@end

NS_ASSUME_NONNULL_END
