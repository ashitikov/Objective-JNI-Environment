//
//  OJNIJavaVM.m
//  OJNITest
//
//  Created by Alexander Shitikov on 15.02.16.
//  Copyright © 2016 Alexander Shitikov. All rights reserved.
//

#import "OJNIJavaVM.h"
#import "OJNIEnvironmentException.h"

@interface OJNIJavaVM ()

@property BOOL isInitialized;

@property (nonatomic, strong, readwrite) OJNIEnv *mainThreadEnv;
@property (nonatomic, strong) NSMapTable *memoryMap;

@end

@implementation OJNIJavaVM {
    @private
    JavaVM *vm;
}

+ (instancetype)sharedVM {
    static OJNIJavaVM *sharedVM = nil;
    
    @synchronized(self) {
        if (sharedVM == nil)
            sharedVM = [[self alloc] init];
    }
    return sharedVM;
}

- (void)initializeJVMWithArgs:(JavaVMInitArgs)args {
    JNIEnv *env;
    
    jint result = JNI_CreateJavaVM(&vm, &env, &args);
    if (result != JNI_OK) {
        [OJNIEnvironmentException pointerExceptionWithReason:@"JavaVM creation failed"];
    } else {
        self.isInitialized = YES;
        
        [self initMemoryMap];
        self.mainThreadEnv = [[OJNIEnv alloc] initWithJNIEnv:env];
    }
}

- (void)initializeJVM {
    JavaVMInitArgs vm_args;
    JavaVMOption options[1];
    options[0].optionString = "-rvm:log=error";
    
    vm_args.version = JNI_VERSION_1_2;
    vm_args.nOptions = 1;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = JNI_FALSE;
    
    [self initializeJVMWithArgs:vm_args];
}

- (void)initMemoryMap {
    // TODO: discuss
    NSPointerFunctionsOptions keyOpts = (NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality);
    NSPointerFunctionsOptions valOpts = (NSPointerFunctionsWeakMemory   | NSPointerFunctionsObjectPersonality);
    
    self.memoryMap = [[NSMapTable alloc] initWithKeyOptions:keyOpts valueOptions:valOpts capacity:16];
}

- (void)throwIfNotInitialized {
    if (!self.isInitialized) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"JavaVM is not initialized. Use [[OJNIJavaVM sharedVM] initializeJVM] to fix this"];
    }
}

- (OJNIEnv *)attachCurrentThread {
    [self throwIfNotInitialized];
    
    JNIEnv *env;
    jint result = (*vm)->AttachCurrentThread(vm, &env, NULL);
    
    if (result != JNI_OK) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"JavaVM thread attaching failed"];
    }
    
    return [[OJNIEnv alloc] initWithJNIEnv:env];
}

- (void)detachCurrentThread:(OJNIEnv *)env {
    [self throwIfNotInitialized];
    
    [self.memoryMap removeObjectForKey:[NSValue valueWithPointer:[env jniEnv]]];
    
    (*vm)->DetachCurrentThread(vm);
}

- (void)associatePointer:(void *)pointer withObject:(id)object {
    if (pointer == NULL)
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"Cannot associate NULL pointer with object"];
    
    [self.memoryMap setObject:object forKey:[NSValue valueWithPointer:pointer]];
}

- (id)retrieveObjectFromMemoryMapWithPointer:(void *)pointer {
    return [self.memoryMap objectForKey:[NSValue valueWithPointer:pointer]];
}

- (void)dealloc {
    if (self.isInitialized)
        (*vm)->DestroyJavaVM(vm);
}

- (OJNIEnv *)getEnv {
    [self throwIfNotInitialized];
    
    JNIEnv *env;
    
    jint result = (*vm)->GetEnv(vm, &env, JNI_VERSION_1_2);
    
    if (result != JNI_OK) {
        return self.mainThreadEnv;
    }
    
    OJNIEnv *wrapper = [self retrieveObjectFromMemoryMapWithPointer:env];
    
    if (wrapper == nil) {
        wrapper = [[OJNIEnv alloc] initWithJNIEnv:env];
        
        [self associatePointer:env withObject:wrapper];
    }
    
    return wrapper;
}

- (void)releaseObject:(jobject)obj {
    [self.memoryMap removeObjectForKey:[NSValue valueWithPointer:obj]];
    
    OJNIEnv *__env = [self attachCurrentThread];
    
    [__env releaseObject:obj];
    
    [self detachCurrentThread:__env];
}

@end
