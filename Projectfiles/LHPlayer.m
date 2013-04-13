//
//  LHPlayer.m
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import "LHPlayer.h"

@implementation LHPlayer

+ (id)mainPlayer;
{
    static LHPlayer *player = nil;
    if (!player) {
        player = [[LHPlayer alloc] init];
    }
    return player;
}

- (void)setScale:(float)scale
{
    self.sprite.scale = scale;
}

- (void)highlightFor:(float)time
{
    NSLog(@"animate");
}

- (void)flashingFor:(float)time
{
    NSLog(@"flashing");
}

- (id)init
{
    if (self = [super init]) {
        self.sprite = [CCSprite spriteWithFile:@"fishkite.png"];
    }
    return self;
}

-(void)update:(ccTime)dt
{
    self.position = CGPointMake(self.position.x, self.position.y - 40*dt);
}



@end
