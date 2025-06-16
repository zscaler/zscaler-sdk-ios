
#ifndef ZscalerSDKErrorCode_h
#define ZscalerSDKErrorCode_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const ZscalerSDKErrorDomain;

typedef NSInteger ZscalerSDKErrorCode NS_TYPED_EXTENSIBLE_ENUM;

/// An unknown error occured
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeUnknown;

/// An input parameter was invalid
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeInvalidParameter;

/// There was no network when starting the tunnel
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeNoNetwork;

/// There was a timeout error
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTimeOut;

/// There was a DNS error
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeDnsFailure;

/// There was an error starting the tunnel
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTunnelError;

/// Permission to start the tunnel was denied
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodePermissionDenied;

/// Tunnel already running
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTunnelAlreadyRunning;

extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTunnelStartPendingInSDK;

/// Connection with Broker was successful, but authentication failed due to configuration error.
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTunnelAuthenticationFailed;

/// Connection with Broker was terminated unexpectedly while attempting to upgrade, resulting in tunnel disconnection.
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeConnectionTerminatedWhileUpgrading;

/// Tunnel upgrade to ZeroTrust tunnel failed due to an unexpected error.
/// The PreLogin tunnel remains active to ensure continued connectivity.
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTunnelUpgradeFailed;


#pragma mark OneIdErrors

/// Failed to sign CSR
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeCsrSignFailure;

/// Invalid tenant name
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeInvalidTenantName;

/// No ZPA Service is registered
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeNoZpaService;

/// No ZPA Service is registered
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeMultipleZpaService;

/// Failed to Revoke Certificate
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeRevokeCertFailed;

/// Token Config not found for given  tenant
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTokenConfigNotFound;

/// Failure parsing jwk
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeJwkParseFailed;

/// Customers Public Key Info is not present
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeCustomerKeyNotPresent;

/// Failure parsing customer Key
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeCustomerKeyParseFailed;

/// Unsupported Key Type
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeUnsupportedKeyType;

/// Failed to verify token signature
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeFailedSignatureValidation;

/// Token is expired
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTokenExpired;

/// Failed to validate token
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTokenValidationFailed;

/// Failed to validate token claim(s)
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeTokenClaimValidationFailed;

/// Property certificate_id is missing from oauth2 client
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeMissingCertificateIdOauth2Client;

/// Private Key is missing from oauth2 client
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeMissingPrivateKeyOAuth2Client;

/// Failure generating Client Assertion
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeFailureGeneratingClientAssertion;

/// Failure generating SAML Assertion
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeFailureGeneratingSamlAssertion;

/// Failure signing SAML Assertion
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeFailureSigningSamlAssertion;

/// Failure serializing SAML Assertion
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeFailureSerializingSamlAssertion;

/// Property certificate_id is missing from saml config
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeMissingCertificateIdSamlConfig;

/// Only JWT Tokens are supported
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeUnsupportedCustomerTokenType;

/// Failed to Fetch HMAC Secret from ZPA
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeHmacSecretFailed;

/// Failed to validate HMAC payload
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeHmacValidationFailed;

/// Missing sub in the Access Token
extern const ZscalerSDKErrorCode ZscalerSDKErrorCodeMissingSubInAccessToken;

NS_ASSUME_NONNULL_END

#endif /* ZscalerSDKErrorCode_h */
