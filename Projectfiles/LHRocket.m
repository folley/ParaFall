//
//  LHRocket.m
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import "LHRocket.h"

@interface LHRocket ()
@property (nonatomic) CGFloat dividiation;
@property (nonatomic) CGFloat time;
@end

@implementation LHRocket

- (id)init
{
    if (self = [super init]) {
        self.time = 0;
        self.sprite = [CCSprite spriteWithFile:@"rakieta.png"];
    }
    return self;
}

-(void)update:(ccTime)dt
{
    self.time += dt;
    self.dividiation = 2*sin(self.time);
    [self setPosition:CGPointMake(self.position.x + 200 * dt, self.position.y + self.dividiation)];
}

@end
