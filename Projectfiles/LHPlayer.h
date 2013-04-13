//
//  LHPlayer.h
//  Test
//
//  Created by Michał Śmiałko on 13.04.2013.
//
//

#import <Foundation/Foundation.h>

@interface LHPlayer : NSObject

@property (nonatomic) CGPoint position;
+ (id)mainPlayer;

- (void)addToLayer:(CCLayer *)layer;

@end

