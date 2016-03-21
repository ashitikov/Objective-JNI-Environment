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
#import "OJNIPrimitiveArrayHelper.h"

#if defined(__OJNI_TYPE__) && defined(__OJNI_PTYPE__)

typedef void(^ CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, ArrayDeallocator))(__OJNI_PTYPE__ *array, int length);

@interface CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) : OJNIPrimitiveArray {
    @protected
    __OJNI_PTYPE__ *sourceArray;
}

CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, Array):(__OJNI_PTYPE__ *)array length:(int)length;
CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length;
CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length freeWhenDone:(BOOL)freeWhenDone;
CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length deallocator:(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, ArrayDeallocator))deallocator;
CONCAT3_NAMES(- (instancetype)initWithPrimitive, __OJNI_TYPE__, Array):(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) *)primitiveArray;

CONCAT3_NAMES(+ (instancetype)arrayWith, __OJNI_TYPE__, Array):(__OJNI_PTYPE__ *)array length:(int)length;
CONCAT3_NAMES(+ (instancetype)arrayWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length;
CONCAT3_NAMES(+ (instancetype)arrayWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length freeWhenDone:(BOOL)freeWhenDone;
CONCAT3_NAMES(+(instancetype)arrayWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length deallocator:(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, ArrayDeallocator))deallocator;
CONCAT3_NAMES(+ (instancetype)arrayWithPrimitive, __OJNI_TYPE__, Array):(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) *)primitiveArray;

CONCAT2_NAMES(- (__OJNI_PTYPE__)__OJNI_PTYPE__, AtIndex):(int)index;
CONCAT2_NAMES(- (void)set, __OJNI_TYPE__):(__OJNI_PTYPE__)value atIndex:(int)index;
- (__OJNI_PTYPE__ *)rawArray;

+ (__OJNI_PTYPE__ *)copiedArray:(__OJNI_PTYPE__ *)array length:(int)length;

@end

#endif

