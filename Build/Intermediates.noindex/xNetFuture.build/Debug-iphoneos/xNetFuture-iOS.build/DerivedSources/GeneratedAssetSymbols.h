#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "off" asset catalog image resource.
static NSString * const ACImageNameOff AC_SWIFT_PRIVATE = @"off";

/// The "on" asset catalog image resource.
static NSString * const ACImageNameOn AC_SWIFT_PRIVATE = @"on";

#undef AC_SWIFT_PRIVATE