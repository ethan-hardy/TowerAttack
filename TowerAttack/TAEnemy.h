//
//  TAEnemy.h
//  TowerAttack
//
//  Created by Ethan Hardy on 2014-07-07.
//  Copyright (c) 2014 Ethan Hardy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TAUnit.h"


@class TABattleScene;

enum TAEnemyGoldReward : NSUInteger {
    TAEnemyGoldRewardAttacker = 10,
    TAEnemyGoldRewardProtector = 20,
    TAEnemyGoldRewardDemon = 50,
    TAEnemyGoldRewardNinja = 30
};

enum TAEnemyXPReward : NSUInteger {
    TAEnemyXPRewardAttacker = 3,
    TAEnemyXPRewardProtector = 5,
    TAEnemyXPRewardDemon = 10,
    TAEnemyXPRewardNinja = 6
};

enum TAEnemyMovementSpeed : NSUInteger {
    TAEnemyMovementSpeedAttacker = 30,
    TAEnemyMovementSpeedProtector = 15,
    TAEnemyMovementSpeedDemon = 100,
    TAEnemyMovementSpeedNinja = 45
};

enum TAEnemyMaximumHealth : NSUInteger {
    TAEnemyMaximumHealthAttacker = 100,
    TAEnemyMaximumHealthProtector = 500,
    TAEnemyMaximumHealthDemon = 70,
    TAEnemyMaximumHealthNinja = 90
};

enum TAEnemyType : NSUInteger {
    TAEnemyTypeAttacker,
    TAEnemyTypeProtector,
    TAEnemyTypeDemon,
    TAEnemyTypeNinja
};

@interface TAEnemy : TAUnit

@property (nonatomic) CGFloat movementSpeed;
@property (nonatomic) CGFloat maximumHealth;
@property (nonatomic) CGFloat currentHealth;
@property (nonatomic, strong) SKSpriteNode *healthBarInside;
@property (nonatomic) NSUInteger goldReward;
@property (nonatomic) NSUInteger xpReward;
@property (nonatomic) BOOL isVibrating;

-(void)finishPath;
-(void)die;
-(void)moveByTimer:(NSTimer *)timer;
-(void)vibrateAtAngle:(CGFloat)angle;

@end
