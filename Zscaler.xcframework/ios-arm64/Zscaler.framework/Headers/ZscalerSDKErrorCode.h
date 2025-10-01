
#ifndef ZscalerSDKErrorCode_h
#define ZscalerSDKErrorCode_h

#import <Foundation/Foundation.h>
#import <Zscaler/ZscalerSDKAttributes.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const ZscalerSDKErrorDomain;

typedef NSInteger ZscalerSDKErrorCode NS_TYPED_EXTENSIBLE_ENUM;

/// An unknown error occured
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeUnknown;

/// An input parameter was invalid
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeInvalidParameter;

/// There was no network when starting the tunnel
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeNoNetwork;

/// There was a timeout error
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTimeOut;

/// There was a DNS error
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeDnsFailure;

/// There was an error starting the tunnel
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTunnelError;

/// Permission to start the tunnel was denied
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodePermissionDenied;

/// Tunnel already running
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTunnelAlreadyRunning;

ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTunnelStartPendingInSDK;

/// Connection with Broker was successful, but authentication failed due to configuration error.
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTunnelAuthenticationFailed;

/// Connection with Broker was terminated unexpectedly while attempting to upgrade, resulting in tunnel disconnection.
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeConnectionTerminatedWhileUpgrading;

/// Tunnel upgrade to ZeroTrust tunnel failed due to an unexpected error.
/// The PreLogin tunnel remains active to ensure continued connectivity.
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTunnelUpgradeFailed;


#pragma mark OneIdErrors

/// Failed to sign CSR
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeCsrSignFailure;

/// Invalid tenant name
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeInvalidTenantName;

/// No ZPA Service is registered
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeNoZpaService;

/// No ZPA Service is registered
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeMultipleZpaService;

/// Failed to Revoke Certificate
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeRevokeCertFailed;

/// Token Config not found for given  tenant
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTokenConfigNotFound;

/// Failure parsing jwk
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeJwkParseFailed;

/// Customers Public Key Info is not present
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeCustomerKeyNotPresent;

/// Failure parsing customer Key
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeCustomerKeyParseFailed;

/// Unsupported Key Type
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeUnsupportedKeyType;

/// Failed to verify token signature
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeFailedSignatureValidation;

/// Token is expired
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTokenExpired;

/// Failed to validate token
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTokenValidationFailed;

/// Failed to validate token claim(s)
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeTokenClaimValidationFailed;

/// Property certificate_id is missing from oauth2 client
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeMissingCertificateIdOauth2Client;

/// Private Key is missing from oauth2 client
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeMissingPrivateKeyOAuth2Client;

/// Failure generating Client Assertion
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeFailureGeneratingClientAssertion;

/// Failure generating SAML Assertion
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeFailureGeneratingSamlAssertion;

/// Failure signing SAML Assertion
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeFailureSigningSamlAssertion;

/// Failure serializing SAML Assertion
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeFailureSerializingSamlAssertion;

/// Property certificate_id is missing from saml config
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeMissingCertificateIdSamlConfig;

/// Only JWT Tokens are supported
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeUnsupportedCustomerTokenType;

/// Failed to Fetch HMAC Secret from ZPA
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeHmacSecretFailed;

/// Failed to validate HMAC payload
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeHmacValidationFailed;

/// Missing sub in the Access Token
ZSDK_EXTERN ZscalerSDKErrorCode const ZscalerSDKErrorCodeMissingSubInAccessToken;

NS_ASSUME_NONNULL_END

#endif /* ZscalerSDKErrorCode_h */
