//
//  MutableDictionarySerialAdapter.h
//  AlcoholScanner
//
//  Created by Александр Поляков on 17.06.16.
//  Copyright © 2016 AGIMA.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MutableDictionarySerialAdapter : NSObject

-(id)objectForKey:(id)aKey;
-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
@end
