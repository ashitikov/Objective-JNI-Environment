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
#import "OJNIJavaException.h"

@implementation OJNIJavaException

- (instancetype)initWithThrowable:(jthrowable)throwable {
    
    NSString *name = [self.class nameOfThrowable:throwable];
    NSString *reason = [self.class reasonOfThrowable:throwable];
    NSString *callStack = [self.class callStackOfThrowable:throwable];
    
    self = [super initWithName:name
                        reason:[self.class productReason:reason stackTrace:callStack]
                      userInfo:nil];
    
    if (self) {
        javaThrowable = throwable;
    }
    
    return self;
}

+ (instancetype)exceptionWithThrowable:(jthrowable)throwable {
    return [[self alloc] initWithThrowable:throwable];
}

+ (NSString *)nameOfThrowable:(jthrowable)throwable {
    return [[OJNIEnv currentEnv] getClassNameOfJavaObject:throwable removePackage:YES];
}

+ (NSString *)reasonOfThrowable:(jthrowable)throwable {
    OJNIEnv *env = [OJNIEnv currentEnv];
    jclass objectClass = [env getObjectClass:throwable];
    jmethodID getLocalizedMessageMethod = [env getMethodID:objectClass
                                                                      name:@"getLocalizedMessage"
                                                                 signature:@"()Ljava/lang/String;"];
    
    jobject localizedMessageObject = [env callObjectMethodOnObject:throwable method:getLocalizedMessageMethod];
    
    [env releaseObject:objectClass];
    
    if (localizedMessageObject == NULL)
        return nil;
    
    return [env newStringFromJavaString:localizedMessageObject utf8Encoding:NO];
}

// TODO: rework
+ (NSString *)callStackOfThrowable:(jthrowable)throwable {
    static jclass stringWriterClass = NULL;
    static jclass printWriterClass = NULL;
    
    OJNIEnv *env = [OJNIEnv currentEnv];
    
    if (stringWriterClass == NULL)
        stringWriterClass = [env findClass:@"java/io/StringWriter"];
    
    if (printWriterClass == NULL)
        printWriterClass = [env findClass:@"java/io/PrintWriter"];
    
    jmethodID stringWriterConstructorMid = [env getMethodID:stringWriterClass name:@"<init>" signature:@"()V"];
    
    jobject stringWriterObject = [env newObject:stringWriterClass method:stringWriterConstructorMid];
    
    jmethodID printWriterConstructorMid = [env getMethodID:printWriterClass name:@"<init>" signature:@"(Ljava/io/Writer;)V"];
    
    jobject printWriterObject = [env newObject:printWriterClass method:printWriterConstructorMid, stringWriterObject];
    
    /// PrintWriter Constructed. Then print in it
    
    jclass objectClass = [env getObjectClass:throwable];
    jmethodID printStackTraceMid = [env getMethodID:objectClass name:@"printStackTrace" signature:@"(Ljava/io/PrintWriter;)V"];
    
    [env callVoidMethodOnObject:throwable method:printStackTraceMid, printWriterObject];
    
    /// Close printwriter
    jmethodID closePrintWriterMid = [env getMethodID:printWriterClass name:@"close" signature:@"()V"];
    [env callVoidMethodOnObject:printWriterObject method:closePrintWriterMid];
    
    jmethodID toStringStringWriterMid = [env getMethodID:stringWriterClass name:@"toString" signature:@"()Ljava/lang/String;"];
    
    jobject stackTrace = [env callObjectMethodOnObject:stringWriterObject method:toStringStringWriterMid];
 
    NSString *result = [env newStringFromJavaString:stackTrace utf8Encoding:NO];
    
    /// release streams
    [env releaseObject:objectClass];
    [[OJNIJavaVM sharedVM] releaseObject:printWriterObject];
    [[OJNIJavaVM sharedVM] releaseObject:stringWriterObject];
    
    return result;
}

+ (NSString *)productReason:(NSString *)reason stackTrace:(NSString *)stackTrace {
    return [NSString stringWithFormat:@"%@ ; Objective-JNI Java Call Stack Trace: \n %@", reason, stackTrace];
}

@end
