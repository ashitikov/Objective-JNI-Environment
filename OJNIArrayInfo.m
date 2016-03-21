//
//  OJNIArrayInfo.m
//  Zdravcity-iOS
//
//  Created by Alexander Shitikov on 16.03.16.
//  Copyright © 2016 A. All rights reserved.
//

#import "OJNIArrayInfo.h"

#import "OJNIEnvironmentException.h"

@implementation OJNIArrayInfo

+ (instancetype)arrayInfoFromJavaArray:(jarray)array environment:(OJNIEnv *)env prefix:(NSString *)prefix {
    OJNIArrayInfo *info = [[self alloc] init];
    
    NSString *identifier = [env getClassNameOfJavaObject:array removePackage:NO];
    
    NSUInteger location = [identifier rangeOfString:@"[" options:NSBackwardsSearch].location;
    
    if (location == NSNotFound)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get information from not array type %@", identifier];
    
    info.dimensions = location + 1;
    info.isPrimitive = (identifier.length - info.dimensions == 1);
    
    if (info.isPrimitive) {
        unichar arrId = [identifier characterAtIndex:info.dimensions];
        
        info.componentType = [self primitiveArrayClassFromId:arrId];
        
        if (info.componentType == nil)
            @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Unable to get primitive array type with signature %c", arrId];
    }
    else {
        NSString *className = [env getComponentTypeClassNameOfArray:array];
        
        info.componentType = [env runtimeClassFromJavaClassName:className prefix:prefix];
        
        if (info.componentType == nil)
            @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Unable to get array type with component's class name %@", className];
    }
    
    return info;
}

+ (Class)primitiveArrayClassFromId:(unichar)arrId {
    switch (arrId) {
        case 'Z':
        return [OJNIPrimitiveBooleanArray class];
        break;
        
        case 'B':
        return [OJNIPrimitiveByteArray class];
        break;
        
        case 'C':
        return [OJNIPrimitiveCharArray class];
        break;
        
        case 'S':
        return [OJNIPrimitiveShortArray class];
        break;
        
        case 'I':
        return [OJNIPrimitiveIntArray class];
        break;
        
        case 'J':
        return [OJNIPrimitiveLongArray class];
        break;
        
        case 'F':
        return [OJNIPrimitiveFloatArray class];
        break;
        
        case 'D':
        return [OJNIPrimitiveDoubleArray class];
        break;
        
        default:
        return nil;
        break;
    }
}

@end
