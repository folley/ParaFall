/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "ContactListener.h"
#import "cocos2d.h"
#import "LHObstacle.h"
#import "LHPlayer.h"
#import "LHContact.h"

void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
	
	if (spriteA != NULL && spriteB != NULL) {
        
        if ([spriteA isKindOfClass:[LHObstacle class]] &&
            [spriteB isKindOfClass:[LHPlayer class]]) {
            
           
            
            NSLog(@"123");
            
        }
        
        if ([spriteB isKindOfClass:[LHObstacle class]] &&
            [spriteA isKindOfClass:[LHPlayer class]]) {
            
            
            NSLog(@"321");
            
        }
        
        
        
        
        
        
	}
}

void ContactListener::EndContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
	
	if (spriteA != NULL && spriteB != NULL) {

	}
}
