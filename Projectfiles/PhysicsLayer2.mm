/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "PhysicsLayer2.h"
#import "Box2DDebugLayer.h"
#import "Sample.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
const float PTM_RATIO = 32.0f;

const int TILESIZE = 32;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;


@interface PhysicsLayer2 (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
@end

@implementation PhysicsLayer2 {
    LeapController *controller;
    bool wait;
    float handInclinationX;
    float handInclinationY;
    float handInclinationZ;
}

@synthesize snot;

- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addListener:self];
    NSLog(@"running");
}

-(id) init
{
	if ((self = [super init]))
	{
        [self run];
        wait = 0;
        handInclinationX = 0.;
        handInclinationY = 0.;
        handInclinationZ = 0.;
        
		CCLOG(@"%@ init", NSStringFromClass([self class]));

		glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		world = new b2World(gravity);
		world->SetAllowSleeping(YES);
		//world->SetContinuousPhysics(YES);
		
		// uncomment this line to draw debug info
		[self enableBox2dDebugDrawing];

		contactListener = new ContactListener();
		world->SetContactListener(contactListener);
		
		// for the screenBorder body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        [self addBlackSpace];
        
//		float widthInMeters = 1440 / PTM_RATIO;
//		float heightInMeters = 900 / PTM_RATIO;
//		b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
//		b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
//		b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
//		b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
//		
//		// Define the static container body, which will provide the collisions at screen borders.
//		b2BodyDef screenBorderDef;
//		screenBorderDef.position.Set(0, 0);
//		b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
//		b2EdgeShape screenBorderShape;
//		
//		// Create fixtures for the four borders (the border shape is re-used)
//		screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//		screenBorderShape.Set(lowerRightCorner, upperRightCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//		screenBorderShape.Set(upperRightCorner, upperLeftCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//		screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
		
//		NSString* message = @"Tap Screen For More Awesome!";
//		if ([CCDirector sharedDirector].currentPlatformIsMac)
//		{
//			message = @"Click Window For More Awesome!";
//		}
		
//		CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:32];
//		[self addChild:label];
//		[label setColor:ccc3(222, 222, 255)];
//		label.position = CGPointMake(screenSize.width / 2, screenSize.height - 50);
		
		// Use the orthogonal tileset for the little boxes
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png" capacity:TILESET_ROWS * TILESET_COLUMNS];
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		// Add a few objects initially
//		for (int i = 0; i < 9; i++)
//		{
//			[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
//		}
//		
//		[self addSomeJoinedBodies:CGPointMake(screenSize.width / 4, screenSize.height - 50)];
		
		[self scheduleUpdate];
		
		[KKInput sharedInput].accelerometerActive = YES;
        
        [self addSnot];
        
        CCSprite *white = [CCSprite spriteWithFile:@"white.png"];
        white.position = ccp(400,1500);
        [self addChild:white z:91];
        
        [white runAction:[CCMoveBy actionWithDuration:7. position:ccp(0,-2400)]];
        
        [self schedule:@selector(turnWaitOn:) interval:1.f];
        [self schedule:@selector(addWhiteSpriteLeft:) interval:4.f];
//        [self schedule:@selector(addWhiteSpriteRight:) interval:3.f];
	}

	return self;
}

-(void)addBlackSpace
{
    CCSprite *black = [CCSprite spriteWithFile:@"black.png"];
    black.position = ccp(720,400);
    [self addChild:black z:91];    
}

-(void)addWhiteSpriteRight:(ccTime)dt
{
//    CCSprite *white = [CCSprite spriteWithFile:@"white.png"];
//    white.scaleX = 2;
//    white.position = ccp(1000,1500);
//    [self addChild:white z:91];
//    
//    [white runAction:[CCMoveBy actionWithDuration:7. position:ccp(0,-2400)]];
}
-(void)addWhiteSpriteLeft:(ccTime)dt
{
    CCSprite *white = [CCSprite spriteWithFile:@"white.png"];
    white.position = ccp(400,1500);
    [self addChild:white z:91];
    white.scaleX = 2;
    
    [white runAction:[CCMoveBy actionWithDuration:7. position:ccp(0,-2400)]];
}

- (void) addSnot
{
    CCSprite *aSnot = [CCSprite spriteWithFile:@"circle2.png"];
    [self addChild:aSnot z:100];
    aSnot.position = ccp(1440/2, 900/2);
    self.snot = aSnot;
    self.snot.tag = 1;
}

- (void)turnWaitOn:(ccTime)dt
{
    wait = true;
}

-(void) dealloc
{
	delete contactListener;
	delete world;

#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(void) enableBox2dDebugDrawing
{
	// Using John Wordsworth's Box2DDebugLayer class now
	// The advantage is that it draws the debug information over the normal cocos2d graphics,
	// so you'll still see the textures of each object.
	const BOOL useBox2DDebugLayer = YES;

	
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;

	UInt32 debugDrawFlags = 0;
	debugDrawFlags += b2Draw::e_shapeBit;
	debugDrawFlags += b2Draw::e_jointBit;
	//debugDrawFlags += b2Draw::e_aabbBit;
	//debugDrawFlags += b2Draw::e_pairBit;
	//debugDrawFlags += b2Draw::e_centerOfMassBit;

	if (useBox2DDebugLayer)
	{
		Box2DDebugLayer* debugLayer = [Box2DDebugLayer debugLayerWithWorld:world
																  ptmRatio:PTM_RATIO
																	 flags:debugDrawFlags];
		[self addChild:debugLayer z:100];
	}
	else
	{
		debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
		if (debugDraw)
		{
			debugDraw->SetFlags(debugDrawFlags);
			world->SetDebugDraw(debugDraw);
		}
	}
}

-(CCSprite*) addRandomSpriteAt:(CGPoint)pos
{
	CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
	
	int idx = CCRANDOM_0_1() * TILESET_COLUMNS;
	int idy = CCRANDOM_0_1() * TILESET_ROWS;
	CGRect tileRect = CGRectMake(TILESIZE * idx, TILESIZE * idy, TILESIZE, TILESIZE);
	CCSprite* sprite = [CCSprite spriteWithTexture:batch.texture rect:tileRect];
	sprite.batchNode = batch;
	sprite.position = pos;
	[batch addChild:sprite];
	
	return sprite;
}

-(void) bodyCreateFixture:(b2Body*)body
{
	// Define another box shape for our dynamic bodies.
	b2PolygonShape dynamicBox;
	float tileInMeters = TILESIZE*10 / PTM_RATIO;
	dynamicBox.SetAsBox(tileInMeters * 0.5f, tileInMeters * 0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 0.3f;
	fixtureDef.friction = 0.5f;
	fixtureDef.restitution = 0.6f;
	body->CreateFixture(&fixtureDef);
	
}

-(void) addSomeJoinedBodies:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(-1, -1);
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* bodyA = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyA];
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* bodyB = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyB];
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(1, 1);
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* bodyC = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyC];
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(bodyA, bodyB, bodyB->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
	
	jointDef.Initialize(bodyB, bodyC, bodyC->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
	
	// create an invisible static body to attach to
	bodyDef.type = b2_staticBody;
	bodyDef.position = [self toMeters:pos];
	b2Body* staticBody = world->CreateBody(&bodyDef);
	jointDef.Initialize(staticBody, bodyA, bodyA->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
}

-(void) addNewSpriteAt:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	
	// assign the sprite as userdata so it's easy to get to the sprite when working with the body
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* body = world->CreateBody(&bodyDef);
	
	[self bodyCreateFixture:body];
}

-(void) update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
	if (director.currentPlatformIsIOS)
	{
		KKInput* input = [KKInput sharedInput];
		if (director.currentDeviceIsSimulator == NO)
		{
			KKAcceleration* acceleration = input.acceleration;
			//CCLOG(@"acceleration: %f, %f", acceleration.rawX, acceleration.rawY);
			b2Vec2 gravity = 10.0f * b2Vec2(acceleration.rawX, acceleration.rawY);
			world->SetGravity(gravity);
		}

		if (input.anyTouchEndedThisFrame)
		{
			[self addNewSpriteAt:[input locationOfAnyTouchInPhase:KKTouchPhaseEnded]];
		}
	}
	else if (director.currentPlatformIsMac)
	{
		KKInput* input = [KKInput sharedInput];
		if (input.isAnyMouseButtonUpThisFrame || CGPointEqualToPoint(input.scrollWheelDelta, CGPointZero) == NO)
		{
			[self addNewSpriteAt:input.mouseLocation];
		}
        
        KKAcceleration* acceleration = input.acceleration;
        //CCLOG(@"acceleration: %f, %f", acceleration.rawX, acceleration.rawY);
//        b2Vec2 gravity = 0.5f * b2Vec2(-handInclinationY, -handInclinationX);
        b2Vec2 gravity = 0.5f * b2Vec2(0, -10);
        world->SetGravity(gravity);
        
        
	}
	
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	float timeStep = 0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(timeStep, velocityIterations, positionIterations);
	
	// for each body, get its assigned sprite and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
		if (sprite != NULL)
		{
			// update the sprite's position to where their physics bodies are
			sprite.position = [self toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
		}
	}
}


// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}


#if DEBUG
-(void) draw
{
	[super draw];

	if (debugDraw)
	{
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
		kmGLPushMatrix();
		world->DrawDebugData();	
		kmGLPopMatrix();
	}
}
#endif

#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification;
{
    NSLog(@"Connected");
    LeapController *aController = (LeapController *)[notification object];
    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification;
{
    NSLog(@"Disconnected");
}

- (void)onExit:(NSNotification *)notification;
{
    NSLog(@"Exited");
}

- (void)onFrame:(NSNotification *)notification;
{
    LeapController *aController = (LeapController *)[notification object];
    LeapFrame *frame = [aController frame:0];
    
    NSArray *gestures = [frame gestures:nil];
    for (int g = 0; g < [gestures count]; g++) {
        LeapGesture *gesture = [gestures objectAtIndex:g];
        switch (gesture.type) {

            case LEAP_GESTURE_TYPE_SWIPE: {
                LeapSwipeGesture *swipeGesture = (LeapSwipeGesture *)gesture;
                NSLog(@"Swipe id: %d, %@, position: %@, direction: %@, speed: %f",
                      swipeGesture.id, [self stringForState:swipeGesture.state],
                      swipeGesture.position, swipeGesture.direction, swipeGesture.speed);
                
                
                int min = (swipeGesture.direction.x < 0)? -1 : 1;
                if(self.snot.tag == 1) {
                    self.snot.tag = 0;
                    [self.snot runAction:[CCSequence actionOne:
                                          
                                          [CCSequence actions:
                                                [CCJumpBy actionWithDuration:0.5 position:ccp(min*300,0) height:-20 jumps:1],
                                                            [CCDelayTime actionWithDuration:0.3],[CCJumpBy actionWithDuration:0.5 position:ccp(min*-300,0) height:20 jumps:1],nil]
                                                           two:[CCCallBlock actionWithBlock:^(void){self.snot.tag = 1;} ]]];
                }
                
                break;
            }

            default:
                NSLog(@"Unknown gesture type");
                break;
        }
    }
    
//    if (([[frame hands] count] > 0) || [[frame gestures:nil] count] > 0)
//        NSLog(@" ");
//    
//    if ([frame hands].count > 0 && wait) {
//        wait = false;
//        LeapHand *hand = [[frame hands] objectAtIndex:0];
//        
//        NSArray *fingers = [hand fingers];
//        
//        LeapVector *avgPos = [[LeapVector alloc] init];
//        for (int i = 0; i < fingers.count; i++) {
//            LeapFinger *finger = [fingers objectAtIndex:i];
//            avgPos = [avgPos plus:[finger tipPosition]];
//        }
//        avgPos = [avgPos divide:[fingers count]];
//        
//        
//        CGPoint point;
//        point.x = avgPos.x;
//        point.y = avgPos.y;
//        if (avgPos.x < 0 || avgPos.x > [CCDirector sharedDirector].winSize.width)
//            point.x = [CCDirector sharedDirector].winSize.width/2;
//        if (avgPos.y < 0 || avgPos.y > [CCDirector sharedDirector].winSize.height)
//            point.y = [CCDirector sharedDirector].winSize.height/2;
//        
//        
//        [self addNewSpriteAt:point];
//    }
    
    
    
    
    
    if ([[frame hands] count] != 0) {
        // Get the first hand
        LeapHand *hand = [[frame hands] objectAtIndex:0];
        
        // Get the hand's sphere radius and palm position
//        NSLog(@"Hand sphere radius: %f mm, palm position: %@",
//              [hand sphereRadius], [hand palmPosition]);
        
        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];
        
        // Calculate the hand's pitch, roll, and yaw angles
//        NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
//              [direction pitch] * LEAP_RAD_TO_DEG,
//              [normal roll] * LEAP_RAD_TO_DEG,
//              [direction yaw] * LEAP_RAD_TO_DEG);
        
        handInclinationX = [direction pitch] * LEAP_RAD_TO_DEG;
        handInclinationY = [normal roll] * LEAP_RAD_TO_DEG;
        handInclinationZ = [direction yaw] * LEAP_RAD_TO_DEG;
    }
    
}

- (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}


@end
