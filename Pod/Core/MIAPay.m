//
//  APViewController.m
//  AliSDKDemo
//
//  Created by 方彬 on 11/29/13.
//  Copyright (c) 2013 Alipay.com. All rights reserved.
//

#import "MIAPay.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#import "MIAAuthV2Info.h"

@interface MIAPay ()

@end

@implementation MIAPay

#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
	static int kNumber = 15;
	
	NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSMutableString *resultStr = [[NSMutableString alloc] init];
	srand((unsigned)time(0));
	for (int i = 0; i < kNumber; i++)
	{
		unsigned index = rand() % [sourceStr length];
		NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
		[resultStr appendString:oneStr];
	}
	return resultStr;
}

#pragma mark -
#pragma mark   ==============点击订单模拟支付行为==============
//
//选中商品调用支付宝极简支付
//
- (void)miaAppPay:(Order *)orders
{
	/*
	 *商户的唯一的parnter和seller。
	 *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
	 */
    
/*============================================================================*/
/*=======================需要填写商户app申请的===================================*/
/*============================================================================*/
	NSString *partner = @"";
    NSString *seller = @"";
    NSString *privateKey = @"";
/*============================================================================*/
/*============================================================================*/
/*============================================================================*/
	
	//partner和seller获取失败,提示
	if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"缺少partner或者seller或者私钥。"
													   delegate:self
											  cancelButtonTitle:@"确定"
											  otherButtonTitles:nil];
		[alert show];
		return;
	}
	
    Order *order = orders;
    if (order == nil) {
        /*
         *生成订单信息及签名
         */
        //将商品信息赋予AlixPayOrder的成员变量
        order = [[Order alloc] init];
        order.partner = partner;
        order.seller = seller;
        order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
        order.productName = @"商品标题"; //商品标题
        order.productDescription = @"商品描述"; //商品描述
        order.amount = [NSString stringWithFormat:@"%.2f", 0.01]; //商品价格
        order.notifyURL =  @"http://www.oks123.com"; //回调URL
        
        order.service = @"mobile.securitypay.pay";
        order.paymentType = @"1";
        order.inputCharset = @"utf-8";
        order.itBPay = @"30m";
        order.showUrl = @"m.alipay.com";
    }
	
	//应用注册scheme,在AlixPayDemo-Info.plist定义URL types
	NSString *appScheme = @"miaapp";
	
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
	NSLog(@"orderSpec = %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
	id<DataSigner> signer = CreateRSADataSigner(privateKey);
	NSString *signedString = [signer signString:orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil) {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
}

@end
