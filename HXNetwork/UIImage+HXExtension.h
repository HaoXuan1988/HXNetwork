//
//  UIImage+HXExtension.h
//  HXNetworkDemo
//
//  Created by 吕浩轩 on 16/4/11.
//  Copyright © 2016年 吕浩轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HXExtension)

- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)imageScaleAspectFillFromTop:(CGSize)frameSize;
-(UIImage*)subImageInRect:(CGRect)rect;
- (UIImage *)imageFillSize:(CGSize)viewsize;
@end
