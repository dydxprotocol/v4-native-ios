#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "jsinspector-modern/tracing/CdpTracing.h"
#import "jsinspector-modern/tracing/PerformanceTracer.h"

FOUNDATION_EXPORT double jsinspector_moderntracingVersionNumber;
FOUNDATION_EXPORT const unsigned char jsinspector_moderntracingVersionString[];

