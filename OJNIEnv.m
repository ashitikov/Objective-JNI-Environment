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
#import "OJNIEnv.h"
#import "OJNIJavaException.h"
#import "OJNIEnvironmentException.h"
#import "OJNIJavaObject.h"

@interface OJNIEnv () {
    JavaVM *vm;
    JNIEnv *env;
}

@property (nonatomic, strong) NSMapTable *memoryMap;

@end

@implementation OJNIEnv

+ (OJNIEnv *)sharedEnv {
    static OJNIEnv *sharedEnv = nil;
    
    @synchronized(self) {
        if (sharedEnv == nil)
            sharedEnv = [[self alloc] init];
    }
    return sharedEnv;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initMemoryMap];
        [self initJavaVM];
    }
    
    return self;
}

- (void)initMemoryMap {
    // TODO: discuss
    NSPointerFunctionsOptions keyOpts = (NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
    NSPointerFunctionsOptions valOpts = (NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality);
    
    self.memoryMap = [[NSMapTable alloc] initWithKeyOptions:keyOpts valueOptions:valOpts capacity:16];
}

- (void)initJavaVM {
    JavaVMInitArgs vm_args;
    JavaVMOption options[1];/*
    options[0].optionString = "-rvm:EnableGCHeapStats";
    options[1].optionString = "-rvm:ms=8M";
    options[2].optionString = "-rvm:log=trace";
    options[3].optionString = "-rvm:mx=16M";*/
    options[0].optionString = "-rvm:log=trace";
    
    vm_args.version = JNI_VERSION_1_2;
    vm_args.nOptions = 0;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = JNI_FALSE;
    
    jint result = JNI_CreateJavaVM(&vm, &env, &vm_args);
    if (result != JNI_OK) {
        [NSException raise:@"Objective-JNI: JNI_CreateJavaVM() failed" format:@"%d", result];
    }
}

- (void)releaseObject:(jobject)obj {
    [self.memoryMap removeObjectForKey:(__bridge id _Nullable)(obj)];
    
    (*env)->DeleteLocalRef(env, obj);
    (*env)->DeleteGlobalRef(env, obj);
}

- (void)dealloc {
    (*vm)->DestroyJavaVM(vm);
}

CALL_METHOD_IMPLEMENTATION(jobject, Object)
CALL_METHOD_IMPLEMENTATION(jboolean, Boolean)
CALL_METHOD_IMPLEMENTATION(jbyte, Byte)
CALL_METHOD_IMPLEMENTATION(jchar, Char)
CALL_METHOD_IMPLEMENTATION(jshort, Short)
CALL_METHOD_IMPLEMENTATION(jint, Int)
CALL_METHOD_IMPLEMENTATION(jlong, Long)
CALL_METHOD_IMPLEMENTATION(jfloat, Float)
CALL_METHOD_IMPLEMENTATION(jdouble, Double)

CALL_STATIC_METHOD_IMPLEMENTATION(jobject, Object)
CALL_STATIC_METHOD_IMPLEMENTATION(jboolean, Boolean)
CALL_STATIC_METHOD_IMPLEMENTATION(jbyte, Byte)
CALL_STATIC_METHOD_IMPLEMENTATION(jchar, Char)
CALL_STATIC_METHOD_IMPLEMENTATION(jshort, Short)
CALL_STATIC_METHOD_IMPLEMENTATION(jint, Int)
CALL_STATIC_METHOD_IMPLEMENTATION(jlong, Long)
CALL_STATIC_METHOD_IMPLEMENTATION(jfloat, Float)
CALL_STATIC_METHOD_IMPLEMENTATION(jdouble, Double)

GET_FIELD_IMPLEMENTATION(jobject, Object)
GET_FIELD_IMPLEMENTATION(jboolean, Boolean)
GET_FIELD_IMPLEMENTATION(jbyte, Byte)
GET_FIELD_IMPLEMENTATION(jchar, Char)
GET_FIELD_IMPLEMENTATION(jshort, Short)
GET_FIELD_IMPLEMENTATION(jint, Int)
GET_FIELD_IMPLEMENTATION(jlong, Long)
GET_FIELD_IMPLEMENTATION(jfloat, Float)
GET_FIELD_IMPLEMENTATION(jdouble, Double)

SET_FIELD_IMPLEMENTATION(jobject, Object)
SET_FIELD_IMPLEMENTATION(jboolean, Boolean)
SET_FIELD_IMPLEMENTATION(jbyte, Byte)
SET_FIELD_IMPLEMENTATION(jchar, Char)
SET_FIELD_IMPLEMENTATION(jshort, Short)
SET_FIELD_IMPLEMENTATION(jint, Int)
SET_FIELD_IMPLEMENTATION(jlong, Long)
SET_FIELD_IMPLEMENTATION(jfloat, Float)
SET_FIELD_IMPLEMENTATION(jdouble, Double)

GET_STATIC_FIELD_IMPLEMENTATION(jobject, Object)
GET_STATIC_FIELD_IMPLEMENTATION(jboolean, Boolean)
GET_STATIC_FIELD_IMPLEMENTATION(jbyte, Byte)
GET_STATIC_FIELD_IMPLEMENTATION(jchar, Char)
GET_STATIC_FIELD_IMPLEMENTATION(jshort, Short)
GET_STATIC_FIELD_IMPLEMENTATION(jint, Int)
GET_STATIC_FIELD_IMPLEMENTATION(jlong, Long)
GET_STATIC_FIELD_IMPLEMENTATION(jfloat, Float)
GET_STATIC_FIELD_IMPLEMENTATION(jdouble, Double)

SET_STATIC_FIELD_IMPLEMENTATION(jobject, Object)
SET_STATIC_FIELD_IMPLEMENTATION(jboolean, Boolean)
SET_STATIC_FIELD_IMPLEMENTATION(jbyte, Byte)
SET_STATIC_FIELD_IMPLEMENTATION(jchar, Char)
SET_STATIC_FIELD_IMPLEMENTATION(jshort, Short)
SET_STATIC_FIELD_IMPLEMENTATION(jint, Int)
SET_STATIC_FIELD_IMPLEMENTATION(jlong, Long)
SET_STATIC_FIELD_IMPLEMENTATION(jfloat, Float)
SET_STATIC_FIELD_IMPLEMENTATION(jdouble, Double)

- (void)callVoidMethodOnObject:(jobject)obj method:(jmethodID)mid, ... {
    if (obj == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call method on NULL object"];
    else if (mid == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call NULL method"];
    
    va_list ap;
    
    va_start(ap, mid);
    (*env)->CallVoidMethodV(env, obj, mid, ap);
    va_end(ap);
    
    [self reportException];
}

- (void)callStaticVoidMethodOnClass:(jclass)cls method:(jmethodID)mid, ... {
    if (cls == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call static method on NULL class"];
    else if (mid == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call NULL method"];
    
    va_list ap;
    
    va_start(ap, mid);
    (*env)->CallStaticVoidMethodV(env, cls, mid, ap);
    va_end(ap);
    
    [self reportException];
}

- (jobject)newObject:(jclass)cls method:(jmethodID)mid, ... {
    if (cls == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot create object with NULL class"];
    else if (mid == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call NULL constructor"];
    
    va_list ap;
    
    jobject result;
    va_start(ap, mid);
    result = (*env)->NewObjectV(env, cls, mid, ap);
    
    [self reportException];
    
    if (result == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Object with class %p and method %p creation failed", cls, mid];
    
    (*env)->NewGlobalRef(env, result);
    
    va_end(ap);
    
    return result;
}

- (jclass)findClass:(NSString *)cls {
    if (cls == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot find NULL class"];
    
    jclass result;
    result = (*env)->FindClass(env, [cls UTF8String]);
    
    [self reportException];
    
    if (result == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Failed to find class %@", cls];
    
    return result;
}

- (jclass)getObjectClass:(jobject)obj {
    if (obj == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get class of NULL object"];
    
    jclass result;
    result = (*env)->GetObjectClass(env, obj);
    
    [self reportException];
    
    return result;
}

- (jobjectArray)innerJavaObjectArrayFromArray:(NSArray *)array
                                 baseClass:(id)baseClass
                               isPrimitive:(BOOL)isPrimitive
                          currentDimension:(int)currentDimension {
    
    int length = (int)[array count];
    
    jclass resultBaseClass = NULL;

    if ([baseClass isKindOfClass:[NSString class]]) {
        // probably interface
        resultBaseClass = [[OJNIMidManager sharedManager] javaClassForClassName:baseClass];
    } else if (isPrimitive) {
        NSMutableString *classIdentifier = [[NSMutableString alloc] init];
        
        for (int i = 0; i < currentDimension; i++) {
            [classIdentifier appendString:@"["];
        }
        [classIdentifier appendString:[baseClass javaArrayIdentifier]];
        
        resultBaseClass = [[OJNIMidManager sharedManager] javaClassForClassName:classIdentifier];
    } else {
        resultBaseClass = [baseClass OJNIClass];
    }
    
    jobjectArray result = (*env)->NewObjectArray(env, length, resultBaseClass, NULL);
    
    for (int i = 0; i < length; i++) {
        id object = [array objectAtIndex:i];
        
        if (currentDimension > 1) {
            (*env)->SetObjectArrayElement(env, result, i, [self innerJavaObjectArrayFromArray:array[i]
                                                                                    baseClass:baseClass
                                                                                  isPrimitive:isPrimitive
                                                                             currentDimension:currentDimension - 1]);
        }
        else if (isPrimitive) {
            (*env)->SetObjectArrayElement(env, result, i, [object javaArray]);
        }
        else {
            (*env)->SetObjectArrayElement(env, result, i, [object javaObject]);
        }
    }
    
    return result;
}


- (jobjectArray)newJavaObjectArrayFromArray:(NSArray *)array
                                  baseClass:(id)baseClass
                                 dimensions:(int)dimensions {
    jobjectArray result;
    Class a = [array class];
    
    BOOL primitive = (![baseClass isKindOfClass:[NSString class]] &&
                      [baseClass isSubclassOfClass:[OJNIPrimitiveArray class]]);
    
    if (primitive)
        dimensions--;
    
    result = [self innerJavaObjectArrayFromArray:array
                                       baseClass:baseClass
                                     isPrimitive:primitive
                                currentDimension:dimensions];
    
    return result;
}

- (NSArray *)innerArrayFromJavaObjectArray:(jobjectArray)array
                                 baseClass:(Class)baseClass
                               classPrefix:(NSString *)classPrefix
                               isPrimitive:(BOOL)isPrimitive
                          currentDimension:(int)currentDimension {
    
    int length = [self lengthOfArray:array];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        jobject object = (*env)->GetObjectArrayElement(env, array, i);
        
        if (currentDimension > 1) {
            [result addObject:[self innerArrayFromJavaObjectArray:object
                                                        baseClass:baseClass
                                                      classPrefix:classPrefix
                                                      isPrimitive:isPrimitive
                                                 currentDimension:currentDimension - 1]];
        }
        else if (isPrimitive) {
            [result addObject:[[baseClass alloc] initWithJavaArray:object]];
        }
        else {
            [result addObject:[OJNIJavaObject retrieveFromJavaObject:object classPrefix:classPrefix]];
        }
        
        // check, needed?
        (*env)->DeleteLocalRef(env, object);
    }
    
    return result;
}

- (NSArray *)newArrayFromJavaObjectArray:(jobjectArray)array
                               baseClass:(Class)baseClass
                             classPrefix:(NSString *)classPrefix
                              dimensions:(int)dimensions {
    NSArray *result;
    
    BOOL primitive = ([baseClass isSubclassOfClass:[OJNIPrimitiveArray class]]);
    
    if (primitive)
        dimensions--;
    
    result = [self innerArrayFromJavaObjectArray:array
                                       baseClass:baseClass
                                     classPrefix:classPrefix
                                     isPrimitive:primitive
                                currentDimension:dimensions];
    
    return result;
}

NEW_ARRAY_METHOD_IMPLEMENTATION(jintArray, Int)
NEW_ARRAY_METHOD_IMPLEMENTATION(jcharArray, Char)
NEW_ARRAY_METHOD_IMPLEMENTATION(jshortArray, Short)
NEW_ARRAY_METHOD_IMPLEMENTATION(jlongArray, Long)
NEW_ARRAY_METHOD_IMPLEMENTATION(jfloatArray, Float)
NEW_ARRAY_METHOD_IMPLEMENTATION(jdoubleArray, Double)
NEW_ARRAY_METHOD_IMPLEMENTATION(jbooleanArray, Boolean)
NEW_ARRAY_METHOD_IMPLEMENTATION(jbyteArray, Byte)

- (jfieldID)getFieldID:(jclass)cls name:(NSString *)name signature:(NSString *)signature isStatic:(BOOL)isStatic {
    if (cls == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get field ID of NULL class"];
    else if (name == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get field ID with NULL name"];
    else if (signature == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get field ID with NULL signature"];
    
    jfieldID result;
    
    if (isStatic)
        result = (*env)->GetStaticFieldID(env, cls, [name UTF8String], [signature UTF8String]);
    else
        result = (*env)->GetFieldID(env, cls, [name UTF8String], [signature UTF8String]);
    
    [self reportException];
    
    if (result == NULL) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"%@Field ID with class %p, name %@ and signature %@ not found", isStatic ? @"Static " : @"", cls, name, signature];
    }
    
    return result;
}

- (jfieldID)getFieldID:(jclass)cls name:(NSString *)name signature:(NSString *)signature {
    return [self getFieldID:cls name:name signature:signature isStatic:NO];
}

- (jfieldID)getStaticFieldID:(jclass)cls name:(NSString *)name signature:(NSString *)signature {
    return [self getFieldID:cls name:name signature:signature isStatic:YES];
}

- (jmethodID)getMethodID:(jclass)cls name:(NSString *)name signature:(NSString *)signature isStatic:(BOOL)isStatic {
    if (cls == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get method ID of NULL class"];
    else if (name == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get method ID with NULL name"];
    else if (signature == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get method ID with NULL signature"];
    
    jmethodID result;
    
    if (isStatic)
        result = (*env)->GetStaticMethodID(env, cls, [name UTF8String], [signature UTF8String]);
    else
        result = (*env)->GetMethodID(env, cls, [name UTF8String], [signature UTF8String]);
    
    [self reportException];
    
    if (result == NULL) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"%@Method ID with class %p, name %@ and signature %@ not found", isStatic ? @"Static " : @"", cls, name, signature];
    }
    
    return result;
}

- (jmethodID)getMethodID:(jclass)cls name:(NSString *)name signature:(NSString *)signature {
    return [self getMethodID:cls name:name signature:signature isStatic:NO];
}

- (jmethodID)getStaticMethodID:(jclass)cls name:(NSString *)name signature:(NSString *)signature {
    return [self getMethodID:cls name:name signature:signature isStatic:YES];
}

- (jsize)lengthOfArray:(jarray)array {
    if (array == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get length of NULL array"];
    
    jsize result;
    result = (*env)->GetArrayLength(env, array);
    
    return result;
}

GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jintArray, int, Int)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jcharArray, char, Char)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jshortArray, short, Short)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jlongArray, long, Long)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jfloatArray, float, Float)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jdoubleArray, double, Double)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jbooleanArray, bool, Boolean)
GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jbyteArray, char, Byte)

- (NSString *)newStringFromJavaString:(jstring)javaString utf8Encoding:(BOOL)utf8Encoding {
    if (javaString == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get NSString of NULL java string"];
    
    NSString *result = nil;
    
    if (utf8Encoding) {
        const char *chars = (*env)->GetStringUTFChars(env, javaString, NULL);
        
        [self reportException];
        
        result = [NSString stringWithUTF8String:chars];
        
        (*env)->ReleaseStringUTFChars(env, javaString, chars);
        
    } else {
        const unichar *chars = (*env)->GetStringChars(env, javaString, NULL);
        
        [self reportException];
        
        jsize length = (*env)->GetStringLength(env, javaString);
        
        result = [NSString stringWithCharacters:chars length:length];
        
        (*env)->ReleaseStringChars(env, javaString, chars);
    }
    
    return result;
}


- (jstring)newJavaStringFromString:(NSString *)string utf8Encoding:(BOOL)utf8Encoding {
    jstring result = NULL;
    
    if (utf8Encoding) {
        const char *chars = [string cStringUsingEncoding:NSUTF8StringEncoding];
        
        result = (*env)->NewStringUTF(env, chars);
    } else {
        int length = (int)string.length;
        
        unichar *chars = malloc(length * sizeof(unichar));
        
        [string getCharacters:chars range:NSMakeRange(0, length)];
        
        result = (*env)->NewString(env, chars, length);
        
        free(chars);
    }
    
    [self reportException];
    
    return result;
}

- (BOOL)isJavaObject:(jobject)obj1 equalToObject:(jobject)obj2 {
    return ((*env)->IsSameObject(env, obj1, obj2) == JNI_TRUE);
}

- (void)associateJavaObject:(jobject)javaObject withObject:(OJNIJavaObject *)object {
    if (javaObject == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot associate NULL java object"];
    
    [self.memoryMap setObject:object forKey:(__bridge id _Nullable)(javaObject)];
}

- (OJNIJavaObject *)retrieveObjectFromMemoryMapWithJavaObject:(jobject)javaObject {
    return [self.memoryMap objectForKey:(__bridge id _Nullable)(javaObject)];
}

// TODO: REWORK!!!
- (NSString *)getClassNameOfJavaObject:(jobject)javaObject {
    static jmethodID mid = NULL;
    
    jclass javaClass = [self getObjectClass:javaObject];
    
    if (mid == NULL) {
        jclass jniClass = [self getObjectClass:javaClass];
        
        mid = [[OJNIEnv sharedEnv] getMethodID:jniClass name:@"getName" signature:@"()Ljava/lang/String;"];
    }
    
    jobject simpleName = [[OJNIEnv sharedEnv] callObjectMethodOnObject:javaClass method:mid];
    
    NSString *result = [self newStringFromJavaString:simpleName utf8Encoding:YES];
    
    // remove package name
    result = [result substringFromIndex:[result rangeOfString:@"." options:NSBackwardsSearch].location + 1];
    
    return result;
}

- (Class)runtimeClassFromJavaObject:(jobject)javaObject prefix:(NSString *)prefix {
    NSString *className = [self getClassNameOfJavaObject:javaObject];
    
    if (className == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get class name of java object %p", javaObject];
    
    NSString *result = [prefix stringByAppendingString:className];
    
    Class resultClass = NSClassFromString(result);
    
    if (resultClass == nil)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Runtime class getting failed for object %p with Objective-C wrapper classname %@", javaObject, result];
    
    return resultClass;
}

- (void)reportException {
    if ((*env)->ExceptionCheck(env)) {
        jthrowable throwable = (*env)->ExceptionOccurred(env);
        
        (*env)->ExceptionClear(env);
        
        // throw translated obj-c exception
        OJNIJavaException *exception = [OJNIJavaException exceptionWithThrowable:throwable];
        
        @throw exception;
    }
}

@end
