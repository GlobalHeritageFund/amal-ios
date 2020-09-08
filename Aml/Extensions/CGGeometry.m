//
//  CGGeometry.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
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

CGRect CGRectInsetToSize(CGRect rect, CGSize newSize) {
    CGFloat horizontalInset = (rect.size.width - newSize.width)/2;
    CGFloat verticalInset = (rect.size.height - newSize.height)/2;

    return CGRectInset(rect, horizontalInset, verticalInset);
}

CGRectEdge CGLeadingEdge() {
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        return CGRectMaxXEdge;
    } else {
        return CGRectMinXEdge;
    }
}

CGRectEdge CGTrailingEdge() {
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        return CGRectMinXEdge;
    } else {
        return CGRectMaxXEdge;
    }

}
