//
//  Util.m
//  CentralECM
//
//  Created by HeungKyoo Han on 10. 5. 17..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "Base64.h"

@implementation Util

+ (NSString*)doCipher:(NSString*)plainText key:(NSString *)key action:(CCOperation)encryptOrDecrypt { 
	const void *vplainText;
	size_t plainTextBufferSize;
 	
	if (encryptOrDecrypt == kCCDecrypt) {
		[Base64 initialize];
 		NSData *EncryptData = [Base64 decode:plainText];
		plainTextBufferSize = [EncryptData length];
		vplainText = [EncryptData bytes];
	}
	else { 		
		NSData *plainTextData = [plainText dataUsingEncoding: NSUTF8StringEncoding]; 
		plainTextBufferSize = [plainTextData length]; 
		vplainText = [plainTextData bytes];
	}
	
	CCCryptorStatus ccStatus;
	uint8_t *bufferPtr = NULL;
	size_t bufferPtrSize = 0;
	size_t movedBytes = 0;
	// uint8_t ivkCCBlockSize3DES;
	
	bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
 
	//NSString *initVec = @"init Vec";
	const void *vkey = (const void *)[key UTF8String];
	//const void *vinitVec = (const void *)[initVec UTF8String];
	/*
	 kCCAlgorithmDES:
	 case kCCAlgorithm3DES:
	 */
	ccStatus = CCCrypt(encryptOrDecrypt,
					   kCCAlgorithmDES,  //kCCAlgorithm3DES
					   kCCOptionPKCS7Padding |kCCOptionECBMode,
					   vkey, 
					   kCCKeySizeDES,  //kCCKeySize3DES,
					   nil, //"init Vec", //iv,
					   vplainText, //"Your Name", //plainText,
					   plainTextBufferSize,
					   (void *)bufferPtr,
					   bufferPtrSize,
					   &movedBytes);
 //	if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
	
	if (ccStatus == kCCParamError) return @"PARAM ERROR";
	else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
	else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
	else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
	else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
	else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
	
 	NSString *result;
	
	if (encryptOrDecrypt == kCCDecrypt) {
 		result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] autorelease];
	}
	else {
		NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
 		[Base64 initialize];
		return [Base64 encode:myData];
  	}
 	return result; 
}



+(NSString *) urlencode: (NSString *) url
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", nil];
	
    int len = [escapeChars count];
	
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < len; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
	
    NSString *out = [NSString stringWithString: temp];
	
    return out;
}

+(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

// Get IP Address
+ (NSString *)getIPAddress {    
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];               
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
} 


@end
