//
//  Macaddress.h
//  CentralECMTablet
//
//  Created by Rusa on 13. 5. 7..
//
//

#import <Foundation/Foundation.h>

@interface Macaddress : NSObject
    char*  getMacAddress(char* macAddress, char* ifName);
@end
