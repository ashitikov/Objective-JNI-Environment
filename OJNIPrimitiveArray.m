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
#import "OJNIPrimitiveArray.h"

#import "OJNIEnv.h"

@implementation OJNIPrimitiveArray

- (instancetype)clone {
    return nil;
}

- (instancetype)initWithNumberArray:(NSArray<NSNumber *> *)numberArray {
    return nil;
}

- (instancetype)initWithJavaArray:(jarray)javaArray {
    return nil;
}

+ (instancetype)arrayWithNumberArray:(NSArray<NSNumber *> *)numberArray {
    return nil;
}

+ (instancetype)arrayWithJavaArray:(jarray)javaArray {
    return nil;
}

+ (NSString *)javaArrayIdentifier {
    return @"[";
}

- (NSString *)javaArrayIdentifier {
    return [self.class javaArrayIdentifier];
}

- (jarray)javaArray {
    return NULL;
}

@end

#define __OJNI_TYPE__ Int
#define __OJNI_PTYPE__ int
#define __OJNI_ARRAY_PTYPE__ jintArray
#define __OJNI_IDENTIFIER__ @"[I"
#include "OJNIPrimitiveArrayTemplate.m"

#define __OJNI_TYPE__ Float
#define __OJNI_PTYPE__ float
#define __OJNI_ARRAY_PTYPE__ jfloatArray
#define __OJNI_IDENTIFIER__ @"[F"
#include "OJNIPrimitiveArrayTemplate.m"

#define __OJNI_TYPE__ Double
#define __OJNI_PTYPE__ double
#define __OJNI_ARRAY_PTYPE__ jdoubleArray
#define __OJNI_IDENTIFIER__ @"[D"
#include "OJNIPrimitiveArrayTemplate.m"

#define __OJNI_TYPE__ Char
#define __OJNI_PTYPE__ char
#define __OJNI_ARRAY_PTYPE__ jcharArray
#define __OJNI_IDENTIFIER__ @"[C"
#include "OJNIPrimitiveArrayTemplate.m"

#define __OJNI_TYPE__ Short
#define __OJNI_PTYPE__ short
#define __OJNI_ARRAY_PTYPE__ jshortArray
#define __OJNI_IDENTIFIER__ @"[S"
#include "OJNIPrimitiveArrayTemplate.m"

#define __OJNI_TYPE__ Long
#define __OJNI_PTYPE__ long
#define __OJNI_ARRAY_PTYPE__ jlongArray
#define __OJNI_IDENTIFIER__ @"[J"
#include "OJNIPrimitiveArrayTemplate.m"

#define __OJNI_TYPE__ Boolean
#define __OJNI_PTYPE__ bool
#define __OJNI_ARRAY_PTYPE__ jbooleanArray
#define __OJNI_IDENTIFIER__ @"[Z"
#include "OJNIPrimitiveArrayTemplate.m"

/*
#define __OJNI_TYPE__ Object
#define __OJNI_PTYPE__ object
#include "OJNIPrimitiveArrayTemplate.m"*/
