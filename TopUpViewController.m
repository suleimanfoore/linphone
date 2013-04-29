//
//  TopUpViewController.m
//  linphone
//
//  Created by lion on 22/04/2013.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TopUpViewController.h"
#import "PhoneMainView.h"

#define kPayPalClientId @"suleiman.yusuf@gmail.com"
#define kPayPalReceiverEmail @"suleiman@hotmail.com"

@interface TopUpViewController ()

@property(nonatomic, strong, readwrite) IBOutlet UIView *successView;

@end

@implementation TopUpViewController

@synthesize balanceText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)refresh:(id)sender{
    NSLog(@"TopUpVV : refresh()");
    balanceText.text = @"£10.90";
}
-(IBAction)topUp:(id)sender {
    UIButton *amount = (UIButton *) sender;
    NSInteger tag = [amount tag];
    NSLog(@"amount selected is %d", tag);
    self.completedPayment = nil;
    
    [[PhoneMainView instance] showTabBar:NO];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithInt:tag];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Call minutes";
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Any customer identifier that you have will work here. Do NOT use a device- or
    // hardware-based identifier.
    NSString *customerId = @"user-11723";
    
    // Set the environment:
    // - For live charges, use PayPalEnvironmentProduction (default).
    // - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
    // - For testing, use PayPalEnvironmentNoNetwork.
    [PayPalPaymentViewController setEnvironment:self.environment];
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:kPayPalClientId
                                                                                                 receiverEmail:kPayPalReceiverEmail
                                                                                                       payerId:customerId
                                                                                                       payment:payment
                                                                                                      delegate:self];
    paymentViewController.hideCreditCardButton = !self.acceptCreditCards;
    
    //[self presentViewController:paymentViewController animated:YES completion:nil];
    [self presentModalViewController:paymentViewController animated:YES];
    
}

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    self.completedPayment = completedPayment;
    self.successView.hidden = NO;
    
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [[PhoneMainView instance] showTabBar:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel {
    NSLog(@"PayPal Payment Canceled");
    self.completedPayment = nil;
    self.successView.hidden = YES;
       [[PhoneMainView instance] showTabBar:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(ZZFlipsideViewController *)controller {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender {
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"PayPal iOS Library Demo";
    self.acceptCreditCards = YES;
    self.environment = PayPalEnvironmentNoNetwork;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.successView.hidden = YES;
      NSLog(@"PayPal iOS SDK version: %@", [PayPalPaymentViewController libraryVersion]);
}

- (void)dealloc{
    [balance release];
    [balanceText release];
    [super dealloc];
}

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"TopUp"
                                                                content:@"TopUpViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar: @"UIMainBar"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
    }
    return compositeDescription;
}


@end
