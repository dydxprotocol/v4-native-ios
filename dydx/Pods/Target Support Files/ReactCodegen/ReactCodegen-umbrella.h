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

#import "RCTModulesConformingToProtocolsProvider.h"
#import "RCTThirdPartyComponentsProvider.h"
#import "react/renderer/components/rnsvg/ComponentDescriptors.h"
#import "react/renderer/components/rnsvg/EventEmitters.h"
#import "react/renderer/components/rnsvg/Props.h"
#import "react/renderer/components/rnsvg/RCTComponentViewHelpers.h"
#import "react/renderer/components/rnsvg/ShadowNodes.h"
#import "react/renderer/components/rnsvg/States.h"
#import "rnsvg/rnsvg.h"
#import "rnsvgJSI.h"
#import "RNVectorIconsSpec/RNVectorIconsSpec.h"
#import "RNVectorIconsSpecJSI.h"

FOUNDATION_EXPORT double ReactCodegenVersionNumber;
FOUNDATION_EXPORT const unsigned char ReactCodegenVersionString[];

