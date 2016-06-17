//
//  MapTableSerialAdapter.h
//  AlcoholScanner
//
//  Created by Александр Поляков on 17.06.16.
//  Copyright © 2016 AGIMA.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapTableSerialAdapter : NSObject

-(instancetype)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger) initialCapacity;
-(id)objectForKey:(id)key;
-(void)setObject:(id)object forKey:(id)key;
-(void)removeObjectForKey:(id)key;
@end
