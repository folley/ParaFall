//
//  LHPlayer.m
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import "LHPlayer.h"

@interface LHPlayer ()

@property (nonatomic, strong) CCSprite *sprite;

@end

@implementation LHPlayer

+ (id)mainPlayer;
{
    static LHPlayer *player = nil;
    if (!player) {
        player = [[LHPlayer alloc] init];
    }
    return player;
}


- (void)setPosition:(CGPoint)position
{
    _position = position;
    self.sprite.position = position;
}

- (id)init
{
    if (self = [super init]) {
        self.sprite = [CCSprite spriteWithFile:@"fishkite.png"];
    }
    return self;
}


- (void)addToLayer:(CCLayer *)layer
{
    [layer addChild:self.sprite];
}

-(void) update:(ccTime)dt
{
    self.position = CGPointMake(self.position.x, self.position.y - 20*dt);
    
}

@end

