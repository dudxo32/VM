//
//  DVTextEncoding.h
//  WebControl
//
//  Created by DevCEL on 10. 12. 21..
//  Copyright 2010 ALS Works. All rights reserved.
//  www.devcel.co.kr

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol DVTextEncodingDelegate <NSObject>
@required
- (void)didEndEncoding:(UIWebView *)saveWeb dec:(NSData *)ed2 ;
- (void)didFailedEncoding:(UIWebView *)saveWeb;
@end


@interface DVTextEncoding : NSObject {
	id<DVTextEncodingDelegate> delegate;
	UIWebView		*saveWeb;
	NSMutableData	*revData;
    NSString        *convencoding;
}
@property (nonatomic, assign) id<DVTextEncodingDelegate> delegate;
@property (nonatomic, retain) UIWebView *saveWeb;
@property (nonatomic, retain) NSMutableData *revData;
@property (nonatomic, retain) NSString      *convencoding;
- (void)koreanWebText:(NSString *)path webview:(UIWebView *)currentWebView;

@end
