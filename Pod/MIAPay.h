//
//  APViewController.h
//  AliSDKDemo
//
//  Created by 方彬 on 11/29/13.
//  Copyright (c) 2013 Alipay.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Order;

@interface MIAPay : NSObject

- (void)miaAppPay:(Order *)orders;

@end
