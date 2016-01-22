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
#import <Foundation/Foundation.h>

#import <jni.h>

@interface OJNIMidManager : NSCache

+ (OJNIMidManager *)sharedManager;

- (jfieldID)fieldIDForStaticMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz;
- (jfieldID)fieldIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz;
- (jfieldID)fieldIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz isStatic:(BOOL)isStatic;

- (jmethodID)methodIDForStaticMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz;
- (jmethodID)methodIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz;
- (jmethodID)methodIDForMethod:(NSString *)method signature:(NSString *)signature inClass:(Class)clazz isStatic:(BOOL)isStatic;

- (jclass)javaClassForClassName:(NSString *)name;

- (void)removeIDSFromClass:(Class)clazz;

@end
