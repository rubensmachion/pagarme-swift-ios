//
//  RSA.h
//  My
//
//  Created by ideawu on 15-2-3.
//  Copyright (c) 2015年 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma once

NS_ASSUME_NONNULL_BEGIN

@interface RSA : NSObject

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSString *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;

@end

NS_ASSUME_NONNULL_END
