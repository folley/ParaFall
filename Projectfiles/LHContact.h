//
//  LHContact.h
//  Test
//
//  Created by Maciej Lobodzinski on 13.04.2013.
//
//

#import <Foundation/Foundation.h>
#import "LHPlayer.h"
#import "LHObstacle.h"

@interface LHContact : NSObject

- (void)crash:(LHPlayer*)player andObstacle:(LHObstacle *)obstacle;

@end
