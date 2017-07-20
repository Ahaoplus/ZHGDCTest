//
//  AppDelegate.h
//  ZHGDCTest
//
//  Created by 张浩 on 2017/6/30.
//  Copyright © 2017年 hzbt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

