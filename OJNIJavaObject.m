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

@implementation OJNIJavaObject

+ (NSString *)OJNIClassName {
    return nil;
}

+ (jclass)OJNIClass {
/*    static jclass javaClass = NULL;
    
    if (javaClass == NULL)
        javaClass =[[OJNIEnv sharedEnv] findClass:[self.class OJNIClassName]];
    
    return javaClass;*/
    
    return [[OJNIEnv sharedEnv] findClass:[self.class OJNIClassName]];
}

- (instancetype)initWithJavaObject:(jobject)obj {
    self = [super init];
    
    if (self) {
        _javaObject = obj;
        
        [[OJNIEnv sharedEnv] associateJavaObject:obj withObject:self];
    }
    
    return self;
}

+ (instancetype)retrieveFromJavaObject:(jobject)obj classPrefix:(NSString *)classPrefix {
    if (obj == NULL)
        return nil;
    
    OJNIJavaObject *retrieved = [[OJNIEnv sharedEnv] retrieveObjectFromMemoryMapWithJavaObject:obj];
    
    if (retrieved != nil)
        return retrieved;
    
    Class runtimeClass = NULL;
    
    @try {
        runtimeClass = [[OJNIEnv sharedEnv] runtimeClassFromJavaObject:obj prefix:classPrefix];
    } @catch (NSException *e) {
        NSLog(@"WARNING! Got an exception while retrieving object from java object %p. Corrupted object? This usual happens while OJNI Environment trying to get class name of object via getClass().getSimpleName() or Objective-C wrapper not found. Check it please. Using runtime OJNIJavaObject instead... Detailed explanation: %@", obj, [e reason]);
        
        return [[OJNIJavaObject alloc] initWithJavaObject:obj];
    }
    
    return [[runtimeClass alloc] initWithJavaObject:obj];
}

- (jobject)javaObject {
    return _javaObject;
}

- (BOOL)isEqual:(id)object {
    return self == object || ([object isKindOfClass:[OJNIJavaObject class]] &&
                              [[OJNIEnv sharedEnv] isJavaObject:[self javaObject] equalToObject:[object javaObject]]);
}

- (void)dealloc {
    [[OJNIMidManager sharedManager] removeIDSFromClass:self.class];
    [[OJNIEnv sharedEnv] releaseObject:_javaObject];
}


@end
