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

@interface OJNIPrimitiveArray : NSObject {
    @protected
    int _length;
}

@property (readonly) int length;

- (instancetype)clone;
- (instancetype)initWithNumberArray:(NSArray <NSNumber *> *)numberArray;
- (instancetype)initWithJavaArray:(jarray)javaArray;

+ (instancetype)arrayWithNumberArray:(NSArray <NSNumber *> *)numberArray;
+ (instancetype)arrayWithJavaArray:(jarray)javaArray;

+ (NSString *)javaArrayIdentifier;
- (NSString *)javaArrayIdentifier;

- (jarray)javaArray;

@end

#define __OJNI_TYPE__ Int
#define __OJNI_PTYPE__ int
#define __OJNI_ARRAY_PTYPE__ jintArray
#define __OJNI_IDENTIFIER__ @"[I"
#include "OJNIPrimitiveArrayTemplate.h"

#define __OJNI_TYPE__ Float
#define __OJNI_PTYPE__ float
#define __OJNI_ARRAY_PTYPE__ jfloatArray
#define __OJNI_IDENTIFIER__ @"[F"
#include "OJNIPrimitiveArrayTemplate.h"

#define __OJNI_TYPE__ Double
#define __OJNI_PTYPE__ double
#define __OJNI_ARRAY_PTYPE__ jdoubleArray
#define __OJNI_IDENTIFIER__ @"[D"
#include "OJNIPrimitiveArrayTemplate.h"

#define __OJNI_TYPE__ Char
#define __OJNI_PTYPE__ char
#define __OJNI_ARRAY_PTYPE__ jcharArray
#define __OJNI_IDENTIFIER__ @"[C"
#include "OJNIPrimitiveArrayTemplate.h"

#define __OJNI_TYPE__ Short
#define __OJNI_PTYPE__ short
#define __OJNI_ARRAY_PTYPE__ jshortArray
#define __OJNI_IDENTIFIER__ @"[S"
#include "OJNIPrimitiveArrayTemplate.h"

#define __OJNI_TYPE__ Long
#define __OJNI_PTYPE__ long
#define __OJNI_ARRAY_PTYPE__ jlongArray
#define __OJNI_IDENTIFIER__ @"[J"
#include "OJNIPrimitiveArrayTemplate.h"

#define __OJNI_TYPE__ Boolean
#define __OJNI_PTYPE__ bool
#define __OJNI_ARRAY_PTYPE__ jbooleanArray
#define __OJNI_IDENTIFIER__ @"[Z"
#include "OJNIPrimitiveArrayTemplate.h"

/*#define __OJNI_TYPE__ Object
#define __OJNI_PTYPE__ object
#include "OJNIPrimitiveArrayTemplate.h"
*/

