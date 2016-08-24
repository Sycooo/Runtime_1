//
//  ViewController.m
//  Runtime_1
//
//  Created by Sycooo on 16/8/24.
//  Copyright © 2016年 Sycooo. All rights reserved.
//

#import "ViewController.h"
#import "Syc.h"
#import <objc/message.h>
#import <objc/runtime.h>

//不提示方法没有声明的警告
//targets --> Enable Strick Checking of objc_msgSend Calls --> NO
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"


@interface ViewController ()

@end

#pragma mark --- 动态添加方法

void eat(id self, SEL _cmd, NSString *param){
    NSLog(@"___> %@ ___> %@ ___> %@",self,NSStringFromSelector(_cmd),param);
}

@interface Cmx : NSObject

@end

@implementation Cmx

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(eat:)) {
        
        class_addMethod(self, sel, (IMP)eat, "v@:@");
    }
    return [super resolveClassMethod:sel];
}

@end


#pragma mark --- 替换方法

@implementation UIImage (Image)

+ (void)load{
    
    Method imageWithName = class_getClassMethod(self, @selector(imageWithName:));
    
    Method imageNamed = class_getClassMethod(self, @selector(imageNamed:));
    
    /*
     *imageWithName 替换 imageNamed
     */
    method_exchangeImplementations(imageWithName, imageNamed);
}

+ (instancetype)imageWithName:(NSString *)name{
    
    UIImage *image = [self imageWithName:@"yoyo.jpg"];
    return image;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self exchangeSelector];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self addSelector];
    });
    
}
- (void)exchangeSelector
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    imgView.image = [UIImage imageNamed:@"papa.jpg"];
    [self.view addSubview:imgView];
}


- (void)addSelector
{
    [[Cmx new] performSelector:@selector(eat:) withObject:@"吃货"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
