//
//  LHNode.h
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import <Foundation/Foundation.h>

@interface LHNode : NSObject

@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic) CGPoint position;

- (void)addToLayer:(CCLayer *)layer;
-(void)update:(ccTime)dt;

@end
