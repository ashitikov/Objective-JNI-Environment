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
#import "OJNIEnvHelper.h"
#import "OJNIPrimitiveArray.h"
#import <jni.h>

@class OJNIJavaObject;

@interface OJNIEnv : NSObject

- (instancetype)initWithJNIEnv:(JNIEnv *)jniEnv;
- (JNIEnv *)jniEnv;

+ (instancetype)currentEnv;

CALL_METHOD_DECLARATION(jobject, Object);
CALL_METHOD_DECLARATION(jboolean, Boolean);
CALL_METHOD_DECLARATION(jbyte, Byte);
CALL_METHOD_DECLARATION(jchar, Char);
CALL_METHOD_DECLARATION(jshort, Short);
CALL_METHOD_DECLARATION(jint, Int);
CALL_METHOD_DECLARATION(jlong, Long);
CALL_METHOD_DECLARATION(jfloat, Float);
CALL_METHOD_DECLARATION(jdouble, Double);

CALL_STATIC_METHOD_DECLARATION(jobject, Object);
CALL_STATIC_METHOD_DECLARATION(jboolean, Boolean);
CALL_STATIC_METHOD_DECLARATION(jbyte, Byte);
CALL_STATIC_METHOD_DECLARATION(jchar, Char);
CALL_STATIC_METHOD_DECLARATION(jshort, Short);
CALL_STATIC_METHOD_DECLARATION(jint, Int);
CALL_STATIC_METHOD_DECLARATION(jlong, Long);
CALL_STATIC_METHOD_DECLARATION(jfloat, Float);
CALL_STATIC_METHOD_DECLARATION(jdouble, Double);

GET_FIELD_DECLARATION(jobject, Object);
GET_FIELD_DECLARATION(jboolean, Boolean);
GET_FIELD_DECLARATION(jbyte, Byte);
GET_FIELD_DECLARATION(jchar, Char);
GET_FIELD_DECLARATION(jshort, Short);
GET_FIELD_DECLARATION(jint, Int);
GET_FIELD_DECLARATION(jlong, Long);
GET_FIELD_DECLARATION(jfloat, Float);
GET_FIELD_DECLARATION(jdouble, Double);

SET_FIELD_DECLARATION(jobject, Object);
SET_FIELD_DECLARATION(jboolean, Boolean);
SET_FIELD_DECLARATION(jbyte, Byte);
SET_FIELD_DECLARATION(jchar, Char);
SET_FIELD_DECLARATION(jshort, Short);
SET_FIELD_DECLARATION(jint, Int);
SET_FIELD_DECLARATION(jlong, Long);
SET_FIELD_DECLARATION(jfloat, Float);
SET_FIELD_DECLARATION(jdouble, Double);

GET_STATIC_FIELD_DECLARATION(jobject, Object);
GET_STATIC_FIELD_DECLARATION(jboolean, Boolean);
GET_STATIC_FIELD_DECLARATION(jbyte, Byte);
GET_STATIC_FIELD_DECLARATION(jchar, Char);
GET_STATIC_FIELD_DECLARATION(jshort, Short);
GET_STATIC_FIELD_DECLARATION(jint, Int);
GET_STATIC_FIELD_DECLARATION(jlong, Long);
GET_STATIC_FIELD_DECLARATION(jfloat, Float);
GET_STATIC_FIELD_DECLARATION(jdouble, Double);

SET_STATIC_FIELD_DECLARATION(jobject, Object);
SET_STATIC_FIELD_DECLARATION(jboolean, Boolean);
SET_STATIC_FIELD_DECLARATION(jbyte, Byte);
SET_STATIC_FIELD_DECLARATION(jchar, Char);
SET_STATIC_FIELD_DECLARATION(jshort, Short);
SET_STATIC_FIELD_DECLARATION(jint, Int);
SET_STATIC_FIELD_DECLARATION(jlong, Long);
SET_STATIC_FIELD_DECLARATION(jfloat, Float);
SET_STATIC_FIELD_DECLARATION(jdouble, Double);

- (void)callVoidMethodOnObject:(jobject)obj method:(jmethodID)mid, ...;
- (void)callStaticVoidMethodOnClass:(jclass)cls method:(jmethodID)mid, ...;
- (jobject)newObject:(jclass)cls method:(jmethodID)mid, ...;
- (void)releaseObject:(jobject)obj;
- (jclass)findClass:(NSString *)cls;
- (jclass)getObjectClass:(jobject)obj;

- (jmethodID)getMethodID:(jclass)cls name:(NSString *)name signature:(NSString *)signature isStatic:(BOOL)isStatic;
- (jmethodID)getMethodID:(jclass)cls name:(NSString *)name signature:(NSString *)signature;
- (jmethodID)getStaticMethodID:(jclass)cls name:(NSString *)name signature:(NSString *)signature;

- (jfieldID)getFieldID:(jclass)cls name:(NSString *)name signature:(NSString *)signature isStatic:(BOOL)isStatic;
- (jfieldID)getFieldID:(jclass)cls name:(NSString *)name signature:(NSString *)signature;
- (jfieldID)getStaticFieldID:(jclass)cls name:(NSString *)name signature:(NSString *)signature;

- (jsize)lengthOfArray:(jarray)array;

- (NSString *)getClassNameOfJavaObject:(jobject)javaObject;
- (Class)runtimeClassFromJavaObject:(jobject)javaObject prefix:(NSString *)prefix;
- (BOOL)isJavaObject:(jobject)obj1 equalToObject:(jobject)obj2;

GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jintArray, int, Int);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jcharArray, char, Char);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jshortArray, short, Short);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jlongArray, long, Long);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jfloatArray, float, Float);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jdoubleArray, double, Double);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jbooleanArray, bool, Boolean);
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jbyteArray, char, Byte);

- (jobjectArray)newJavaObjectArrayFromArray:(NSArray *)array
                                  baseClass:(id)baseClass
                                 dimensions:(int)dimensions;

- (NSArray *)newArrayFromJavaObjectArray:(jobjectArray)array
                               baseClass:(Class)baseClass
                             classPrefix:(NSString *)classPrefix
                              dimensions:(int)dimensions;

NEW_ARRAY_METHOD_DECLARATION(jintArray, Int);
NEW_ARRAY_METHOD_DECLARATION(jcharArray, Char);
NEW_ARRAY_METHOD_DECLARATION(jshortArray, Short);
NEW_ARRAY_METHOD_DECLARATION(jlongArray, Long);
NEW_ARRAY_METHOD_DECLARATION(jfloatArray, Float);
NEW_ARRAY_METHOD_DECLARATION(jdoubleArray, Double);
NEW_ARRAY_METHOD_DECLARATION(jbooleanArray, Boolean);
NEW_ARRAY_METHOD_DECLARATION(jbyteArray, Byte);

- (NSString *)newStringFromJavaString:(jstring)javaString utf8Encoding:(BOOL)utf8Encoding;
- (jstring)newJavaStringFromString:(NSString *)string utf8Encoding:(BOOL)utf8Encoding;

@end
