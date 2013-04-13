//
//  LHRaspberry.m
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import "LHRaspberry.h"

@implementation LHRaspberry

- (id)init
{
    if (self = [super init]) {
        self.sprite = [CCSprite spriteWithFile:@"malina2.png"];
    }
    return self;
}

- (void)update:(ccTime)dt
{
    
}

@end
