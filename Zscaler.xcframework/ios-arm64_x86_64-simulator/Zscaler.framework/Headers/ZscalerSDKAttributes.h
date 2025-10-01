
#if defined(__cplusplus)
#define ZSDK_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define ZSDK_EXTERN extern __attribute__((visibility ("default")))
#endif

# define ZSDK_PUBLIC __attribute__((visibility ("default")))
