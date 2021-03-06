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
        
        CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(0, 20)];
        CCMoveBy *moveDown = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(0, -20)];
        CCSequence *seq = [CCSequence actions:moveUp, moveDown, nil];
        CCRepeatForever *repeatSeq = [CCRepeatForever actionWithAction:seq];
        [self.sprite runAction:repeatSeq];
        
    }
    return self;
}

@end
