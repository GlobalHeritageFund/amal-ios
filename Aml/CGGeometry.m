//
//  CGGeometry.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CGGeometry.h"

CGRect CGRectTrim(CGRect rect, CGFloat amount, CGRectEdge edge) {
    CGRect trimmedRect;
    CGRectDivide(rect, &(CGRect){}, &trimmedRect, amount, edge);
    return trimmedRect;
}

CGSize CGSizeFitting(CGSize original, CGSize maximum) {
    CGSize final = CGSizeZero;

    CGFloat aspectWidth = maximum.width / original.width;
    CGFloat aspectHeight = maximum.height / original.height;
    CGFloat aspectRatio = MIN (aspectWidth, aspectHeight);

    final.width = original.width * aspectRatio;
    final.height = original.height * aspectRatio;
    return final;
}


