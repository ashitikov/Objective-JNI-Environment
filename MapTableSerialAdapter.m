//
//  MapTableSerialAdapter.m
//  AlcoholScanner
//
//  Created by Александр Поляков on 17.06.16.
//  Copyright © 2016 AGIMA.mobile. All rights reserved.
//

#import "MapTableSerialAdapter.h"

@interface MapTableSerialAdapter ()

@property (nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSMapTable *mapTable;
@end

@implementation MapTableSerialAdapter

- (instancetype)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity {
    if (self = [super init]) {
        self.queue = dispatch_queue_create("ru.agima.mobile.Objective-JNI-Environment.MapTableSerialAdapterQueue", DISPATCH_QUEUE_SERIAL);
        self.mapTable = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:initialCapacity];
    }
    return self;
}

- (void)setObject:(id)object forKey:(id)key {
    __weak NSMapTable *mapTable = self.mapTable;
    dispatch_sync(self.queue, ^{
        [mapTable setObject:object forKey:key];
    });
}

- (id)objectForKey:(id)key {
    __weak NSMapTable *mapTable = self.mapTable;
    __block id value;
    dispatch_sync(self.queue, ^{
        value = [mapTable objectForKey:key];
    });
    return value;
}

- (void)removeObjectForKey:(id)key {
    __weak NSMapTable *mapTable = self.mapTable;
    dispatch_sync(self.queue, ^{
        [mapTable removeObjectForKey:key];
    });
}

@end
