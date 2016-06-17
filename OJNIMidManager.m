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
#import "OJNIMidManager.h"

#import "OJNIEnv.h"
#import "OJNIJavaObject.h"
#import "OJNIEnvironmentException.h"
#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
#import "MutableDictionarySerialAdapter.h"
#endif

@interface OJNIClassStorage : NSObject {
    @private
    jclass _classPointer;
}

#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
@property (nonatomic, strong) MutableDictionarySerialAdapter *mids;
#else
@property (nonatomic, strong) NSMutableDictionary *mids;
#endif

- (void)setClassPointer:(jclass)classPointer;
- (jclass)classPointer;

@end

@implementation OJNIClassStorage

- (void)setClassPointer:(jclass)classPointer {
    _classPointer = classPointer;
}

- (jclass)classPointer {
    return _classPointer;
}

@end

@implementation OJNIMidManager

+ (OJNIMidManager *)sharedManager {
    static OJNIMidManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (jfieldID)fieldIDForStaticMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz {
    return [self fieldIDForMethod:method signature:signature inClass:clazz isStatic:YES];
}
- (jfieldID)fieldIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz {
    return [self fieldIDForMethod:method signature:signature inClass:clazz isStatic:NO];
}

- (jfieldID)fieldIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz isStatic:(BOOL)isStatic {
    if (![clazz isSubclassOfClass:[OJNIJavaObject class]]) {
        [OJNIEnvironmentException pointerExceptionWithReason:@"Failed to get fieldID for non-java class %@", clazz];
    }
    
    NSString *key = [clazz OJNIClassName];
    
    OJNIClassStorage *storage = [self objectForKey:key];
    
    if (storage == nil) {
        storage = [[OJNIClassStorage alloc] init];
        
        [storage setClassPointer:[clazz OJNIClass]];
#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
        [storage setMids:[[MutableDictionarySerialAdapter alloc] init]];
#else
        [storage setMids:[[NSMutableDictionary alloc] init]];
#endif
        [self setObject:storage forKey:key];
    }
    
    NSString *methodKey = [method stringByAppendingString:signature];
    NSValue *midValue = [storage.mids objectForKey:methodKey];
    
    if (midValue == nil) {
        jfieldID mid = [[OJNIEnv currentEnv] getFieldID:[storage classPointer]
                                                  name:method
                                             signature:signature
                                              isStatic:isStatic];
            [storage.mids setObject:[NSValue valueWithPointer:mid] forKey:methodKey];
        return mid;
    }
    
    return [midValue pointerValue];
}

- (jmethodID)methodIDForStaticMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz {
    return [self methodIDForMethod:method signature:signature inClass:clazz isStatic:YES];
}
- (jmethodID)methodIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz {
    return [self methodIDForMethod:method signature:signature inClass:clazz isStatic:NO];
}

- (jmethodID)methodIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz isStatic:(BOOL)isStatic {
    if (![clazz isSubclassOfClass:[OJNIJavaObject class]]) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Failed to get methodID for non-java class %@", clazz];
    }
    
    NSString *key = [clazz OJNIClassName];
    
    OJNIClassStorage *storage = [self objectForKey:key];
    
    if (storage == nil) {
        storage = [[OJNIClassStorage alloc] init];
        
        [storage setClassPointer:[clazz OJNIClass]];
#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
        [storage setMids:[[MutableDictionarySerialAdapter alloc] init]];
#else
        [storage setMids:[[NSMutableDictionary alloc] init]];
#endif

        [self setObject:storage forKey:key];
    }
    
    NSString *methodKey = [method stringByAppendingString:signature];
    NSValue *midValue = [storage.mids objectForKey:methodKey];
    
    if (midValue == nil) {
        jmethodID mid = [[OJNIEnv currentEnv] getMethodID:[storage classPointer]
                                                    name:method
                                               signature:signature
                                                isStatic:isStatic];
        
        [storage.mids setObject:[NSValue valueWithPointer:mid] forKey:methodKey];
        
        return mid;
    }

    return [midValue pointerValue];
}

- (jclass)javaClassForClass:(Class)clazz {
    return [clazz OJNIClass];
}

- (jclass)javaClassForClassName:(NSString *)name {
    OJNIClassStorage *storage = [self objectForKey:name];
    
    if (storage == nil) {
        storage = [[OJNIClassStorage alloc] init];
        
        [storage setClassPointer:[[OJNIEnv currentEnv] findClass:name]];
#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
        [storage setMids:[[MutableDictionarySerialAdapter alloc] init]];
#else
        [storage setMids:[[NSMutableDictionary alloc] init]];
#endif
        [self setObject:storage forKey:name];
    }
    
    return [storage classPointer];
}

- (void)removeIDSFromClass:(Class)clazz {
    if (![clazz isSubclassOfClass:[OJNIJavaObject class]]) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Failed to remove IDS for non-java class %@", clazz];
    }
    
    NSString *key = [clazz OJNIClassName];
    
    [self removeObjectForKey:key];
}

@end
