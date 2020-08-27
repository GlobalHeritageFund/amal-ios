//
//  CautionViewController.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 7/16/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "CautionViewController.h"

@interface CautionViewController ()

@end

@implementation CautionViewController

- (IBAction)privacyPolicyButtonTapped:(id)sender {
    [self open:@"https://globalheritagefund.org/index.php/news-resources/library/privacy-policy/"];
}

- (IBAction)termsOfServicesButtonTapped:(id)sender {
    [self open:@"http://amal.global/terms-of-service/"];
}

- (void)open:(NSString *)link {
    NSURL *url = [[NSURL alloc] initWithString:link];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


@end
