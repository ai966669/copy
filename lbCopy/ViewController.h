//
//  ViewController.h
//  lbCopy
//
//  Created by ai966669 on 16/8/30.
//  Copyright © 2016年 ai966669. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (copy,nonatomic) NSMutableString *aCopyMStr;

@property (strong,nonatomic) NSMutableString *strongMStr;

@property (weak,nonatomic) NSMutableString *weakMStr;

@property (assign,nonatomic) NSMutableString *assignMStr;


@property (copy,nonatomic) NSString *aCopyStr;

@property (strong,nonatomic) NSString *strongStr;

@property (weak,nonatomic) NSString *weakStr;

@property (assign,nonatomic) NSString *assignStr;


@property (copy,nonatomic) NSMutableArray *aCopyMArr;

@property (strong,nonatomic) NSMutableArray *strongMArr;

@property (weak,nonatomic) NSMutableArray *weakMArr;

@property (assign,nonatomic) NSMutableArray *assignMArr;



@property (copy,nonatomic) NSArray *aCopyArr;

@property (strong,nonatomic) NSArray *strongArr;

@property (weak,nonatomic) NSArray *weakArr;

@property (assign,nonatomic) NSArray *assignArr;

@end

