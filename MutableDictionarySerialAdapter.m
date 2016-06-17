//
//  MutableDictionarySerialAdapter.m
//  AlcoholScanner
//
//  Created by Александр Поляков on 17.06.16.
//  Copyright © 2016 AGIMA.mobile. All rights reserved.
//

#import "MutableDictionarySerialAdapter.h"

@interface MutableDictionarySerialAdapter ()

@property (nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSMutableDictionary* dictionary;
@end

@implementation MutableDictionarySerialAdapter

-(instancetype)init
{
    if (self = [super init])
    {
        self.queue = dispatch_queue_create("MutableDictionarySerialAdapterQueue", DISPATCH_QUEUE_SERIAL);
        self.dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)objectForKey:(id)aKey
{
    __block id value;
    __weak NSMutableDictionary* dictionary = self.dictionary;
    dispatch_sync(self.queue, ^{
        value = [dictionary objectForKey:aKey];
    });
    return value;
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    __weak NSMutableDictionary* dictionary = self.dictionary;
    dispatch_sync(self.queue, ^{
        [dictionary setObject:anObject forKey:aKey];
    });
}

@end
