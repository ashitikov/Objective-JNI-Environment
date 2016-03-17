//
//  OJNIJavaVM.h
//  OJNITest
//
//  Created by Alexander Shitikov on 15.02.16.
//  Copyright © 2016 Alexander Shitikov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJNIEnv.h"

@interface OJNIJavaVM : NSObject

@property (nonatomic, strong, readonly) OJNIEnv *mainThreadEnv;

+ (instancetype)sharedVM;

- (void)initializeJVMWithArgs:(JavaVMInitArgs)args;
- (void)initializeJVM;

- (OJNIEnv *)attachCurrentThread;
- (void)detachCurrentThread:(OJNIEnv *)env;

- (void)associatePointer:(void *)pointer withObject:(id)object;
- (id)retrieveObjectFromMemoryMapWithPointer:(void *)pointer;

- (OJNIEnv *)getEnv;

- (void)releaseObject:(jobject)obj;

@end
