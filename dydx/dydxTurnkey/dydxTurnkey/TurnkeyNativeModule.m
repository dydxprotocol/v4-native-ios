//
//  TurnkeyNativeModule.m
//  dydxTurnkey
//
//  Created by Rui Huang on 16/07/2025.
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(TurnkeyNativeModule, RCTEventEmitter)

/**
  `RCT_EXTERN_METHOD` in React Native allows exposing native methods to the JavaScript bridge.
 
  It follows the syntax: `RCT_EXTERN_METHOD(methodName:(paramType)internalParamName ...)`
  
  For one argument: `RCT_EXTERN_METHOD(methodName:(ParamType)internalParamName)`
 
  For multiple arguments: `RCT_EXTERN_METHOD(methodName:(ParamType1)internalParamName1 [externalParamName2]:(ParamType2)internalParamName2 ...)`
 */
RCT_EXTERN_METHOD(onJsResponse
                  :(NSString) callbackId
                  :(NSString) result)

RCT_EXTERN_METHOD(onAuthRouteToWallet)
RCT_EXTERN_METHOD(onAuthRouteToDesktopQR)
RCT_EXTERN_METHOD(onAuthCompleted
                  :(NSString) onboardingSignature
                  :(NSString) evmAddress
                  :(NSString) svmAddress
                  :(NSString) mnemonics
                  :(NSString) loginMethod
                  :(NSString) userEmail
                  :(NSString) dydxAddress)

RCT_EXTERN_METHOD(onAppleAuthRequest
                  :(NSString) nonce)

RCT_EXTERN_METHOD(onTrackingEvent
                  :(NSString) eventName
                  :(NSDictionary *)eventParams)

@end
