//
//  LHObstacle.m
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import "LHObstacle.h"

@implementation LHObstacle

- (id)init
{
    if (self = [super init]) {
        self.sprite = [CCSprite spriteWithFile:@"fishkite.png"];
    }
    return self;
}

@end
