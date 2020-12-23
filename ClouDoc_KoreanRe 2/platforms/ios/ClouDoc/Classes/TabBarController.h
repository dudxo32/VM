//
//  TabBarController.h
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 6. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TabBarController : UITabBarController <UITabBarControllerDelegate> {

	BOOL	m_bServerTab;
	BOOL	m_bClientTab;
}

@property (nonatomic, assign) BOOL	m_bServerTab;
@property (nonatomic, assign) BOOL	m_bClientTab;

@end

