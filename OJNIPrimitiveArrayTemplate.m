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

@interface CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) ()

@property BOOL freeWhenDone;
@property (nonatomic, copy) CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, ArrayDeallocator) deallocator;

@end

@implementation CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array)

CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, Array):(__OJNI_PTYPE__ *)array length:(int)length {
    __OJNI_PTYPE__ *copied = [CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) copiedArray:array length:length];
    
    return [self CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):copied length:length freeWhenDone:YES];
}

CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length {
    return [self CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):array length:length freeWhenDone:NO];
}

CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length freeWhenDone:(BOOL)freeWhenDone {
    self = [super init];
    
    if (self) {
        sourceArray = array;
        
        _length = length;
        self.freeWhenDone = freeWhenDone;
    }
    
    return self;
}

CONCAT3_NAMES(- (instancetype)initWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length deallocator:(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, ArrayDeallocator))deallocator {
    self = [self CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):array length:length];
    
    if (self) {
        self.deallocator = deallocator;
    }
    
    return self;
}

CONCAT3_NAMES(- (instancetype)initWithPrimitive, __OJNI_TYPE__, Array):(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) *)primitiveArray {
    return [self CONCAT3_NAMES(initWith, __OJNI_TYPE__, Array):[primitiveArray rawArray] length:[primitiveArray length]];
}

- (instancetype)initWithNumberArray:(NSArray<NSNumber *> *)numberArray {
    __OJNI_PTYPE__ *arr = malloc(numberArray.count * sizeof(__OJNI_PTYPE__));
    
    for (int i = 0; i < numberArray.count; i++) {

        // in some cases bool can be defined by system like _Bool, so NSNumber class
        // has no selector called _BoolValue.
        // By temporary undefing this fixes the problem
        #pragma push_macro("bool")
            #undef bool
        
            arr[i] = NSNUMBER_VALUE(numberArray[i], __OJNI_PTYPE__);
        #pragma pop_macro("bool")
    }
    
    return [self CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):arr length:(int)numberArray.count freeWhenDone:YES];
}

- (instancetype)initWithJavaArray:(jarray)javaArray {
    return [[OJNIEnv sharedEnv] CONCAT3_NAMES(primitive, __OJNI_TYPE__, ArrayFromJavaArray):javaArray];
}

CONCAT3_NAMES(+ (instancetype)arrayWith, __OJNI_TYPE__, Array):(__OJNI_PTYPE__ *)array length:(int)length {
    return [[self alloc] CONCAT3_NAMES(initWith, __OJNI_TYPE__, Array):array length:length];
}

CONCAT3_NAMES(+ (instancetype)arrayWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length {
    return [[self alloc] CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):array length:length];
}

CONCAT3_NAMES(+ (instancetype)arrayWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length freeWhenDone:(BOOL)freeWhenDone {
    return [[self alloc] CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):array length:length freeWhenDone:freeWhenDone];
}

CONCAT3_NAMES(+(instancetype)arrayWith, __OJNI_TYPE__, ArrayNoCopy):(__OJNI_PTYPE__ *)array length:(int)length deallocator:(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, ArrayDeallocator))deallocator {
    return [[self alloc] CONCAT3_NAMES(initWith, __OJNI_TYPE__, ArrayNoCopy):array length:length deallocator:deallocator];
}

CONCAT3_NAMES(+ (instancetype)arrayWithPrimitive, __OJNI_TYPE__, Array):(CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) *)primitiveArray {
    return [[self alloc] CONCAT3_NAMES(initWithPrimitive, __OJNI_TYPE__, Array):primitiveArray];
}

+ (instancetype)arrayWithNumberArray:(NSArray<NSNumber *> *)numberArray {
    return [[self alloc] initWithNumberArray:numberArray];
}

CONCAT2_NAMES(- (__OJNI_PTYPE__)__OJNI_PTYPE__, AtIndex):(int)index {
    return sourceArray[index];
}

CONCAT2_NAMES(- (void)set, __OJNI_TYPE__):(__OJNI_PTYPE__)value atIndex:(int)index {
    sourceArray[index] = index;
}

- (__OJNI_PTYPE__ *)rawArray {
    return sourceArray;
}

+ (__OJNI_PTYPE__ *)copiedArray:(__OJNI_PTYPE__ *)array length:(int)length {
    __OJNI_PTYPE__ *copied = malloc(length * sizeof(__OJNI_PTYPE__));
    
    memcpy(copied, array, length * sizeof(__OJNI_PTYPE__));
    
    return copied;
}

- (instancetype)clone {
    return [[CONCAT3_NAMES(OJNIPrimitive, __OJNI_TYPE__, Array) alloc] CONCAT3_NAMES(initWithPrimitive, __OJNI_TYPE__, Array):self];
}

- (jarray)javaArray {
    return [[OJNIEnv sharedEnv] CONCAT3_NAMES(newJava, __OJNI_TYPE__, ArrayFromArray):self];
}

+ (NSString *)javaArrayIdentifier {
    return __OJNI_IDENTIFIER__;
}

- (void)dealloc {
    if (self.freeWhenDone) {
        free(sourceArray);
    } else if (self.deallocator != nil) {
        self.deallocator(sourceArray, _length);
    }
}

@end

#endif
