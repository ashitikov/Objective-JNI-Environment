//
//  OJNIJavaVM.m
//  OJNITest
//
//  Created by Alexander Shitikov on 15.02.16.
//  Copyright © 2016 Alexander Shitikov. All rights reserved.
//

#import "OJNIJavaVM.h"
#import "OJNIEnvironmentException.h"
#import <pthread.h>
#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
#import "MapTableSerialAdapter.h"
#endif

@interface OJNIJavaVM ()

@property BOOL isInitialized;

@property (nonatomic, strong, readwrite) OJNIEnv *mainThreadEnv;
#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
@property (nonatomic, strong) MapTableSerialAdapter *memoryMap;
#else
@property (nonatomic, strong) NSMapTable *memoryMap;
#endif
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

- (void)initializeJVMWithArgs:(NSArray<NSString *> *)args {
    JNIEnv *env;

    JavaVMInitArgs *parsed = [self vmArgsFromArray:args];
    
    jint result = JNI_CreateJavaVM(&vm, (void**)&env, parsed);
    if (result != JNI_OK) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"JavaVM creation failed"];
    } else {
        self.isInitialized = YES;
        
        [self initMemoryMap];
        self.mainThreadEnv = [[OJNIEnv alloc] initWithJNIEnv:env];
    }
    
    free(parsed->options);
    free(parsed);
}

- (JavaVMInitArgs *)vmArgsFromArray:(NSArray<NSString *> *)array {
    JavaVMInitArgs *vm_args = malloc(sizeof(JavaVMInitArgs));
    JavaVMOption *options = malloc(array.count * sizeof(JavaVMOption));
    
    for (NSInteger i = 0; i < array.count; i++) {
        options[i].optionString = (char *)[array[i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    vm_args->nOptions = (int)array.count;
    vm_args->version = JNI_VERSION_1_2;
    vm_args->ignoreUnrecognized = JNI_FALSE;
    vm_args->options = options;
    
    return vm_args;
}

- (void)initializeJVM {
    [self initializeJVMWithArgs:@[@"-rvm:log=error"]];
}

- (void)initMemoryMap {
    // reason for change: NSPointerFunctionsObjectPersonality is not in NSMapTableOptions
    NSMapTableOptions keyOpts = (NSMapTableStrongMemory | NSMapTableObjectPointerPersonality);
    NSMapTableOptions valOpts = (NSMapTableWeakMemory   | NSMapTableObjectPointerPersonality);

#ifdef OJNI_STORAGE_SERIAL_ADAPTERS
    self.memoryMap = [[MapTableSerialAdapter alloc] initWithKeyOptions:keyOpts valueOptions:valOpts capacity:16];
#else
    self.memoryMap = [[NSMapTable alloc] initWithKeyOptions:keyOpts valueOptions:valOpts capacity:16];
#endif
}

- (void)throwIfNotInitialized {
    if (!self.isInitialized) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"JavaVM is not initialized. Use [[OJNIJavaVM sharedVM] initializeJVM] to fix this"];
    }
}

- (OJNIEnv *)attachCurrentThread {
    [self throwIfNotInitialized];
    
    JNIEnv *env;
    jint result = (*vm)->AttachCurrentThread(vm, (void**)&env, NULL);
    
    if (result != JNI_OK) {
        @throw [OJNIEnvironmentException pointerExceptionWithReason:@"JavaVM thread attaching failed"];
    }
    
    OJNIEnv *retrieved = [self retrieveObjectFromMemoryMapWithPointer:env];
    
    if (retrieved == nil)
        retrieved = [[OJNIEnv alloc] initWithJNIEnv:env];
    
    pthread_key_t key_t;
    pthread_key_create(&key_t, onThreadExit);
    pthread_setspecific(key_t, env);
    
    return retrieved;
}

- (void)detachCurrentThread {
    [self throwIfNotInitialized];
    
    (*vm)->DetachCurrentThread(vm);
}

- (void)detachCurrentThread:(JNIEnv *)env {
    [self throwIfNotInitialized];
    [self.memoryMap removeObjectForKey:[NSValue valueWithPointer:env]];
    
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
    
    jint result = (*vm)->GetEnv(vm, (void**)&env, JNI_VERSION_1_2);
    
    if (result != JNI_OK) {
        if (result == JNI_EDETACHED) {
            return [self attachCurrentThread];
        }
        
        return self.mainThreadEnv;
    }
    
    // TODO should we cache env pointer?
    OJNIEnv *wrapper = [self retrieveObjectFromMemoryMapWithPointer:env];
    
    if (wrapper == nil) {
        wrapper = [[OJNIEnv alloc] initWithJNIEnv:env];
    }
    
    return wrapper;
}

- (void)releaseObject:(jobject)obj {
        [self.memoryMap removeObjectForKey:[NSValue valueWithPointer:obj]];
    
    OJNIEnv *__env = [self getEnv];
    
    [__env releaseObject:obj];
}

void onThreadExit (void *environment)
{
    [[OJNIJavaVM sharedVM] detachCurrentThread:environment];
}

@end
