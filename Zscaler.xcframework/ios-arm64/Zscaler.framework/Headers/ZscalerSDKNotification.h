
#ifndef ZscalerNotificationType_h
#define ZscalerNotificationType_h

#include <Foundation/NSNotification.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSString * ZscalerSDKNotificationNameUserInfoKey;
extern const NSString * ZscalerSDKNotificationMessageUserInfoKey;

extern const NSNotificationName ZscalerSDKTunnelDisconnected;
extern const NSNotificationName ZscalerSDKTunnelConnected;
extern const NSNotificationName ZscalerSDKTunnelReconnecting;
extern const NSNotificationName ZscalerSDKTunnelAuthenticationRequired;
extern const NSNotificationName ZscalerSDKTunnelResourceBlocked;

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
extern const NSNotificationName ZscalerSDKProxyStartFailed;


NS_ASSUME_NONNULL_END

#endif /* ZscalerNotificationType_h */
