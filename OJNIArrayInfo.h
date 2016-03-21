//
//  OJNIArrayInfo.h
//  Zdravcity-iOS
//
//  Created by Alexander Shitikov on 16.03.16.
//  Copyright © 2016 A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OJNIEnv.h"

@interface OJNIArrayInfo : NSObject

@property (nonatomic) BOOL isPrimitive;
@property (nonatomic) Class componentType;
@property (nonatomic) NSUInteger dimensions;

+ (instancetype)arrayInfoFromJavaArray:(jarray)array environment:(OJNIEnv *)env prefix:(NSString *)prefix;

@end
