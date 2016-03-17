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
#import "OJNIEnvironmentException.h"

static const NSString *exceptionPrefixReason = @"Objective-JNI Environment Exception: ";

@implementation OJNIEnvironmentException

+ (instancetype)pointerExceptionWithReason:(NSString *)reason, ... {
    va_list ap;
    
    va_start(ap, reason);
    NSString *resultReason = [exceptionPrefixReason stringByAppendingString:[[NSString alloc] initWithFormat:reason arguments:ap]];
    va_end(ap);
    
    return [[self alloc] initWithName:NSStringFromClass(self.class) reason:resultReason userInfo:nil];
}

+ (instancetype)unknownException {
    NSString *resultReason = [exceptionPrefixReason stringByAppendingString:@"Unknown"];
    
    return [[self alloc] initWithName:NSStringFromClass(self.class) reason:resultReason userInfo:nil];
}

@end
