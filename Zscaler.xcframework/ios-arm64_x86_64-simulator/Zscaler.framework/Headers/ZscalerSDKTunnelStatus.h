
#ifndef ZscalerSDKTunnnelStatus_h
#define ZscalerSDKTunnnelStatus_h

#include <Foundation/Foundation.h>
#import <Zscaler/ZscalerSDKAttributes.h>
#import <Zscaler/ZscalerSDKTunnelType.h>

NS_ASSUME_NONNULL_BEGIN

ZSDK_PUBLIC
@interface ZscalerSDKTunnelStatus : NSObject

@property (nonatomic, strong, readonly) NSString* tunnelConnectionState;
@property (nonatomic, readonly) ZscalerSDKTunnelType tunnelType;

- (instancetype)initWithTunnelConnectionState:(NSString*)connectionState
                                   tunnelType:(ZscalerSDKTunnelType)type;

@end

NS_ASSUME_NONNULL_END

#endif /* ZscalerSDKTunnnelStatus_h */
