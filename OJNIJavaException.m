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
    return [[OJNIEnv sharedEnv] getClassNameOfJavaObject:throwable];
    /*
    jclass objectClass = [[OJNIEnv sharedEnv] getObjectClass:throwable];
    jmethodID getClassMethod = [[OJNIEnv sharedEnv] getMethodID:objectClass
                                                           name:@"getClass"
                                                      signature:@"()Ljava/lang/Class;"];
    
    jobject throwableJavaClassObject = [[OJNIEnv sharedEnv] callObjectMethodOnObject:throwable method:getClassMethod];
    jclass throwableJavaClassObjectClass = [[OJNIEnv sharedEnv] getObjectClass:throwableJavaClassObject];
    
    jmethodID getClassNameMethod = [[OJNIEnv sharedEnv] getMethodID:throwableJavaClassObjectClass name:@"getName" signature:@"()Ljava/lang/String;"];
    
    jobject throwableJavaNameString = [[OJNIEnv sharedEnv] callObjectMethodOnObject:throwableJavaClassObject method:getClassNameMethod];
    
   return [[OJNIEnv sharedEnv] newStringFromJavaString:throwableJavaNameString utf8Encoding:NO];*/
}

+ (NSString *)reasonOfThrowable:(jthrowable)throwable {
    jclass objectClass = [[OJNIEnv sharedEnv] getObjectClass:throwable];
    jmethodID getLocalizedMessageMethod = [[OJNIEnv sharedEnv] getMethodID:objectClass
                                                                      name:@"getLocalizedMessage"
                                                                 signature:@"()Ljava/lang/String;"];
    
    jobject localizedMessageObject = [[OJNIEnv sharedEnv] callObjectMethodOnObject:throwable method:getLocalizedMessageMethod];
    
    if (localizedMessageObject == NULL)
        return nil;
    
    return [[OJNIEnv sharedEnv] newStringFromJavaString:localizedMessageObject utf8Encoding:NO];
}

// TODO: rework
+ (NSString *)callStackOfThrowable:(jthrowable)throwable {
    static jclass stringWriterClass = NULL;
    static jclass printWriterClass = NULL;
    
    if (stringWriterClass == NULL)
        stringWriterClass = [[OJNIEnv sharedEnv] findClass:@"java/io/StringWriter"];
    
    if (printWriterClass == NULL)
        printWriterClass = [[OJNIEnv sharedEnv] findClass:@"java/io/PrintWriter"];
    
    jmethodID stringWriterConstructorMid = [[OJNIEnv sharedEnv] getMethodID:stringWriterClass name:@"<init>" signature:@"()V"];
    
    jobject stringWriterObject = [[OJNIEnv sharedEnv] newObject:stringWriterClass method:stringWriterConstructorMid];
    
    jmethodID printWriterConstructorMid = [[OJNIEnv sharedEnv] getMethodID:printWriterClass name:@"<init>" signature:@"(Ljava/io/Writer;)V"];
    
    jobject printWriterObject = [[OJNIEnv sharedEnv] newObject:printWriterClass method:printWriterConstructorMid, stringWriterObject];
    
    /// PrintWriter Constructed. Then print in it
    
    jclass objectClass = [[OJNIEnv sharedEnv] getObjectClass:throwable];
    jmethodID printStackTraceMid = [[OJNIEnv sharedEnv] getMethodID:objectClass name:@"printStackTrace" signature:@"(Ljava/io/PrintWriter;)V"];
    
    [[OJNIEnv sharedEnv] callVoidMethodOnObject:throwable method:printStackTraceMid, printWriterObject];
    
    /// Close printwriter
    jmethodID closePrintWriterMid = [[OJNIEnv sharedEnv] getMethodID:printWriterClass name:@"close" signature:@"()V"];
    [[OJNIEnv sharedEnv] callVoidMethodOnObject:printWriterObject method:closePrintWriterMid];
    
    jmethodID toStringStringWriterMid = [[OJNIEnv sharedEnv] getMethodID:stringWriterClass name:@"toString" signature:@"()Ljava/lang/String;"];
    
    jobject stackTrace = [[OJNIEnv sharedEnv] callObjectMethodOnObject:stringWriterObject method:toStringStringWriterMid];
 
    NSString *result = [[OJNIEnv sharedEnv] newStringFromJavaString:stackTrace utf8Encoding:NO];
    
    /// release streams
    
    [[OJNIEnv sharedEnv] releaseObject:printWriterObject];
    [[OJNIEnv sharedEnv] releaseObject:stringWriterObject];
    
    return result;
}

+ (NSString *)productReason:(NSString *)reason stackTrace:(NSString *)stackTrace {
    return [NSString stringWithFormat:@"%@ ; Objective-JNI Java Call Stack Trace: \n %@", reason, stackTrace];
}

@end
