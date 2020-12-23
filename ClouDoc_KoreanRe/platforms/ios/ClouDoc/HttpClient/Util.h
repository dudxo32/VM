//
//  Util.h
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 5. 17..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface Util : NSObject {

}
+ (NSString*) doCipher: (NSString*) plainText key: (NSString *)key action: (CCOperation)encryptOrDecrypt; 
+ (NSString *) urlencode: (NSString *) url;
+ (NSString*) sha1:(NSString*)input;
+ (NSString *) md5:(NSString *) input;
+ (NSString *)getIPAddress;
@end
