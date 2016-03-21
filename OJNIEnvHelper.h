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
#ifndef OJNIEnvHelper_h
#define OJNIEnvHelper_h

#define SET_STATIC_FIELD_DECLARATION(jtype, Type)                            \
- (void)setStatic##Type##Field:(jobject)obj field:(jfieldID)fid value:(jtype)value

#define SET_STATIC_FIELD_IMPLEMENTATION(jtype, Type)                         \
SET_STATIC_FIELD_DECLARATION(jtype, Type) {                                    \
if (obj == NULL)                                                    \
@throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get static field of NULL object"]; \
else if (fid == NULL)                                                  \
@throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get static NULL field"];          \
\
(*env)->SetStatic##Type##Field(env, obj, fid, value);                     \
\
[self reportException];                                             \
}

#define GET_STATIC_FIELD_DECLARATION(jtype, Type)                            \
- (jtype)getStatic##Type##Field:(jobject)obj field:(jfieldID)fid

#define GET_STATIC_FIELD_IMPLEMENTATION(jtype, Type)                         \
GET_STATIC_FIELD_DECLARATION(jtype, Type) {                                    \
if (obj == NULL)                                                    \
@throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get static field of NULL object"]; \
else if (fid == NULL)                                                  \
@throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get static NULL field"];          \
\
jtype result = (*env)->GetStatic##Type##Field(env, obj, fid);             \
\
[self reportException];                                             \
\
return result;                                                      \
}

#define SET_FIELD_DECLARATION(jtype, Type)                            \
- (void)set##Type##Field:(jobject)obj field:(jfieldID)fid value:(jtype)value

#define SET_FIELD_IMPLEMENTATION(jtype, Type)                         \
SET_FIELD_DECLARATION(jtype, Type) {                                    \
    if (obj == NULL)                                                    \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get field of NULL object"]; \
    else if (fid == NULL)                                                  \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get NULL field"];          \
                                                                        \
    (*env)->Set##Type##Field(env, obj, fid, value);                     \
                                                                        \
    [self reportException];                                             \
}

#define GET_FIELD_DECLARATION(jtype, Type)                            \
- (jtype)get##Type##Field:(jobject)obj field:(jfieldID)fid

#define GET_FIELD_IMPLEMENTATION(jtype, Type)                         \
GET_FIELD_DECLARATION(jtype, Type) {                                    \
    if (obj == NULL)                                                    \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get field of NULL object"]; \
    else if (fid == NULL)                                                  \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot get NULL field"];          \
                                                                        \
    jtype result = (*env)->Get##Type##Field(env, obj, fid);             \
                                                                        \
    [self reportException];                                             \
                                                                        \
    return result;                                                      \
}

#define CALL_METHOD_DECLARATION(jtype, Type)                            \
- (jtype)call##Type##MethodOnObject:(jobject)obj method:(jmethodID)mid, ...

#define CALL_METHOD_IMPLEMENTATION(jtype, Type)                         \
CALL_METHOD_DECLARATION(jtype, Type) {                                  \
    if (obj == NULL)                                                    \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call method on NULL object"]; \
    else if (mid == NULL)                                               \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call NULL method"]; \
    va_list ap;                                                         \
                                                                        \
    jtype result;                                                       \
    va_start(ap, mid);                                                  \
    result = (*env)->Call##Type##MethodV(env, obj, mid, ap);            \
    va_end(ap);                                                         \
                                                                        \
    [self reportException];                                             \
                                                                        \
    return result;                                                      \
}

#define CALL_STATIC_METHOD_DECLARATION(jtype, Type)                             \
- (jtype)callStatic##Type##MethodOnClass:(jclass)cls method:(jmethodID)mid, ...

#define CALL_STATIC_METHOD_IMPLEMENTATION(jtype, Type)                          \
CALL_STATIC_METHOD_DECLARATION(jtype, Type) {                                   \
    if (cls == NULL)                                                            \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call statoc method on NULL class"]; \
    else if (mid == NULL)                                                       \
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot call NULL method"]; \
    va_list ap;                                                                 \
                                                                                \
    jtype result;                                                               \
    va_start(ap, mid);                                                          \
    result = (*env)->CallStatic##Type##MethodV(env, cls, mid, ap);              \
    va_end(ap);                                                                 \
                                                                                \
    [self reportException];                                                     \
                                                                                \
    return result;                                                              \
}

#define NEW_ARRAY_METHOD_DECLARATION(jtype, Type)                            \
- (jtype)newJava##Type##ArrayFromArray:(OJNIPrimitive##Type##Array *)array

#define NEW_ARRAY_METHOD_IMPLEMENTATION(jtype, Type)                         \
NEW_ARRAY_METHOD_DECLARATION(jtype, Type) {                                  \
    jtype result;                                                            \
    result = (*env)->New##Type##Array(env, [array length]);                           \
                                                                                \
    (*env)->Set##Type##ArrayRegion(env, result, 0, [array length], [array rawArray]);    \
                                                                                \
    [self reportException];                                                         \
                                                                                \
    return result;                                                              \
}

#define GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jtypearray, ptype, Type)                            \
- (OJNIPrimitive##Type##Array *)primitive##Type##ArrayFromJavaArray:(jtypearray)array

#define GET_PRIMITIVE_ARRAY_METHOD_IMPLEMENTATION(jtypearray, ptype, Type)                         \
GET_PRIMITIVE_ARRAY_METHOD_DECLARATION(jtypearray, ptype, Type) {                                  \
    jsize length = [self lengthOfArray:array];  \
                                                \
    ptype *arr = malloc(length * sizeof(ptype));    \
                                                \
    (*env)->Get##Type##ArrayRegion(env, array, 0, length, arr);  \
    [self reportException];                                                        \
    return [OJNIPrimitive##Type##Array arrayWith##Type##ArrayNoCopy:arr length:length freeWhenDone:YES];    \
}

#define GLOBALIZE(localReference) \
    jobject __global = (*env)->NewGlobalRef(env, localReference); \
    (*env)->DeleteLocalRef(env, localReference);

#endif /* OJNIEnvHelper_h */
