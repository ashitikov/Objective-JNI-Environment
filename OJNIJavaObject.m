/*
 * Copyright 2016 Alexander Shitikov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import "OJNIJavaObject.h"
#import "OJNIArrayInfo.h"

@implementation OJNIJavaObject

+ (NSString *)OJNIClassName {
    return nil;
}

+ (jclass)OJNIClass {
    return [[OJNIEnv currentEnv] findClass:[self.class OJNIClassName]];
}

- (instancetype)initWithJavaObject:(jobject)obj {
    self = [super init];
    
    if (self) {
        _javaObject = obj;
        
        [[OJNIJavaVM sharedVM] associatePointer:obj withObject:self];
    }
    
    return self;
}

+ (id)retrieveFromJavaObject:(jobject)obj classPrefix:(NSString *)classPrefix {
    if (obj == NULL)
        return nil;
    
    OJNIEnv *env = [OJNIEnv currentEnv];
    
    OJNIJavaObject *retrieved = [[OJNIJavaVM sharedVM] retrieveObjectFromMemoryMapWithPointer:obj];
    
    if (retrieved != nil)
        return retrieved;
    
    @try {
        if ([env isJavaObjectArray:obj]) {
            OJNIArrayInfo *info = [OJNIArrayInfo arrayInfoFromJavaArray:obj environment:env prefix:classPrefix];
            
            if (info.dimensions > 1 || !info.isPrimitive) {
                return [env newArrayFromJavaObjectArray:obj baseClass:info.componentType classPrefix:classPrefix dimensions:(int)info.dimensions];
            } else {
                return [[info.componentType alloc] initWithJavaArray:obj];
            }
        }
        
        Class runtimeClass = [env runtimeClassFromJavaObject:obj prefix:classPrefix];
        
        return [[runtimeClass alloc] initWithJavaObject:obj];
    } @catch (NSException *e) {
        NSLog(@"WARNING! Got an exception while retrieving object from java object %p. Corrupted object? This usual happens when OJNI Environment trying to get class name of object via getClass().getName() or Objective-C wrapper not found. Check it please. Using runtime OJNIJavaObject instead... Detailed explanation: %@", obj, [e reason]);
        
        return [[OJNIJavaObject alloc] initWithJavaObject:obj];
    }
}

- (jobject)javaObject {
    return _javaObject;
}

- (BOOL)isEqual:(id)object {
    return self == object || ([object isKindOfClass:[OJNIJavaObject class]] &&
                              [[OJNIEnv currentEnv] isJavaObject:[self javaObject] equalToObject:[object javaObject]]);
}

- (void)dealloc {
    [[OJNIMidManager sharedManager] removeIDSFromClass:self.class];
    [[OJNIJavaVM sharedVM] releaseObject:_javaObject];
}


@end
