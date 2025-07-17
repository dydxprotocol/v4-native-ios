/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import <Foundation/Foundation.h>

#import "RCTThirdPartyComponentsProvider.h"
#import <React/RCTComponentViewProtocol.h>

@implementation RCTThirdPartyComponentsProvider

+ (NSDictionary<NSString *, Class<RCTComponentViewProtocol>> *)thirdPartyFabricComponents
{
  return @{
		@"RNSVGCircle": NSClassFromString(@"RNSVGCircle"), // react-native-svg
		@"RNSVGClipPath": NSClassFromString(@"RNSVGClipPath"), // react-native-svg
		@"RNSVGDefs": NSClassFromString(@"RNSVGDefs"), // react-native-svg
		@"RNSVGEllipse": NSClassFromString(@"RNSVGEllipse"), // react-native-svg
		@"RNSVGFeBlend": NSClassFromString(@"RNSVGFeBlend"), // react-native-svg
		@"RNSVGFeColorMatrix": NSClassFromString(@"RNSVGFeColorMatrix"), // react-native-svg
		@"RNSVGFeComposite": NSClassFromString(@"RNSVGFeComposite"), // react-native-svg
		@"RNSVGFeFlood": NSClassFromString(@"RNSVGFeFlood"), // react-native-svg
		@"RNSVGFeGaussianBlur": NSClassFromString(@"RNSVGFeGaussianBlur"), // react-native-svg
		@"RNSVGFeMerge": NSClassFromString(@"RNSVGFeMerge"), // react-native-svg
		@"RNSVGFeOffset": NSClassFromString(@"RNSVGFeOffset"), // react-native-svg
		@"RNSVGFilter": NSClassFromString(@"RNSVGFilter"), // react-native-svg
		@"RNSVGForeignObject": NSClassFromString(@"RNSVGForeignObject"), // react-native-svg
		@"RNSVGGroup": NSClassFromString(@"RNSVGGroup"), // react-native-svg
		@"RNSVGImage": NSClassFromString(@"RNSVGImage"), // react-native-svg
		@"RNSVGLine": NSClassFromString(@"RNSVGLine"), // react-native-svg
		@"RNSVGLinearGradient": NSClassFromString(@"RNSVGLinearGradient"), // react-native-svg
		@"RNSVGMarker": NSClassFromString(@"RNSVGMarker"), // react-native-svg
		@"RNSVGMask": NSClassFromString(@"RNSVGMask"), // react-native-svg
		@"RNSVGPath": NSClassFromString(@"RNSVGPath"), // react-native-svg
		@"RNSVGPattern": NSClassFromString(@"RNSVGPattern"), // react-native-svg
		@"RNSVGRadialGradient": NSClassFromString(@"RNSVGRadialGradient"), // react-native-svg
		@"RNSVGRect": NSClassFromString(@"RNSVGRect"), // react-native-svg
		@"RNSVGSvgView": NSClassFromString(@"RNSVGSvgView"), // react-native-svg
		@"RNSVGSymbol": NSClassFromString(@"RNSVGSymbol"), // react-native-svg
		@"RNSVGTSpan": NSClassFromString(@"RNSVGTSpan"), // react-native-svg
		@"RNSVGText": NSClassFromString(@"RNSVGText"), // react-native-svg
		@"RNSVGTextPath": NSClassFromString(@"RNSVGTextPath"), // react-native-svg
		@"RNSVGUse": NSClassFromString(@"RNSVGUse"), // react-native-svg
  };
}

@end
