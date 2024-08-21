//
//  NSObject+Class.h
//  Utilities
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Class)

- (NSArray<NSString *> *)classNames;
- (NSString *)className;

@end

NS_ASSUME_NONNULL_END
