//
//  LHNode.m
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import "LHNode.h"

@implementation LHNode

- (void)setPosition:(CGPoint)position
{
    _position = position;
    self.sprite.position = position;
}

- (void)addToLayer:(CCLayer *)layer
{
    [layer addChild:self.sprite];
}

-(void)update:(ccTime)dt
{
    // ... you can override this method
}

@end
