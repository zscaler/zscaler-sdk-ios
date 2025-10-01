
#ifndef ZscalerSDKTunnelType_h
#define ZscalerSDKTunnelType_h

#import <Foundation/Foundation.h>
#import <Zscaler/ZscalerSDKAttributes.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger ZscalerSDKTunnelType NS_TYPED_EXTENSIBLE_ENUM;

ZSDK_EXTERN ZscalerSDKTunnelType const ZscalerSDKTunnelTypeUnknown;
ZSDK_EXTERN ZscalerSDKTunnelType const ZscalerSDKTunnelTypePreLogin;
ZSDK_EXTERN ZscalerSDKTunnelType const ZscalerSDKTunnelTypeZeroTrust;

NS_ASSUME_NONNULL_END

#endif /* ZscalerSDKTunnelType_h */
