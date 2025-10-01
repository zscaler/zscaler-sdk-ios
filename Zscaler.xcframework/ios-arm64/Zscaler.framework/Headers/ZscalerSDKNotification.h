
#ifndef ZscalerNotificationType_h
#define ZscalerNotificationType_h

#include <Foundation/NSNotification.h>
#import <Zscaler/ZscalerSDKAttributes.h>

NS_ASSUME_NONNULL_BEGIN

ZSDK_EXTERN NSString const * ZscalerSDKNotificationNameUserInfoKey;
ZSDK_EXTERN NSString const * ZscalerSDKNotificationMessageUserInfoKey;

ZSDK_EXTERN NSNotificationName const ZscalerSDKTunnelDisconnected;
ZSDK_EXTERN NSNotificationName const ZscalerSDKTunnelConnected;
ZSDK_EXTERN NSNotificationName const ZscalerSDKTunnelReconnecting;
ZSDK_EXTERN NSNotificationName const ZscalerSDKTunnelAuthenticationRequired;
ZSDK_EXTERN NSNotificationName const ZscalerSDKTunnelResourceBlocked;

/// Indicates that ZscalerSDK has failed to set up it’s proxy. Requests using the proxy will fail.
/// There are a few options for recovery:
/// <ol>
///   <li>
///     Wait and try to restart the ZscalerSDK tunnel.
///   </li>
///   <li>
///     Call ZscalerSDK.resetProxyPortAndRequireSessionRecreation(), then invalidate and recreate all your ZscalerSDK-configured sessions.
///     If using automatic configuration, invalidate and recreate <em>all</em> URLSessions.
///   </li>
/// </ol>
ZSDK_EXTERN NSNotificationName const ZscalerSDKProxyStartFailed;


NS_ASSUME_NONNULL_END

#endif /* ZscalerNotificationType_h */
