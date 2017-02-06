//
//  InAppPurchaseManager.m
//
//  Created by Osipov Stanislav on 1/15/13.
//

#import <IapppayKit/IapppayKit.h>

#import "InAppPurchaseManager.h"
#import "ISNDataConvertor.h"

#import "SKProduct+LocalizedPrice.h"
#include "iAdBannerController.h"

#import "QSHelper.h"

#include "CCLuaEngine.h"
#include "cocos2d.h"

@class ViewController;

@interface InAppPurchaseManager()  {
    int	_payResultCallBack;
}

@end

@implementation InAppPurchaseManager

static InAppPurchaseManager * _instance;

static NSMutableDictionary* _views;

+ (InAppPurchaseManager *) instance {
    
    if (_instance == nil){
        _instance = [[InAppPurchaseManager alloc] init];
    }
    
    return _instance;
}

-(id) init {
    NSLog(@"init");
    if(self = [super init]){
        _views = [[NSMutableDictionary alloc] init];
        _productIdentifiers = [[NSMutableArray alloc] init];
        _products           = [[NSMutableDictionary alloc] init];
        
        _storeServer        = [[TransactionServer alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_storeServer];
    }
    return self;
}

-(void) dealloc {
    [_productIdentifiers release];
    [_storeServer release];
    [super dealloc];
}


- (void)loadStore {
    NSLog(@"loadStore....");
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:_productIdentifiers]];

    request.delegate = self;
    [request start];
    
}

- (void) requestInAppSettingState {
    if ([SKPaymentQueue canMakePayments]) {
        //UnitySendMessage("IOSInAppPurchaseManager", "onStoreKitStart", "1");
    } else {
        //UnitySendMessage("IOSInAppPurchaseManager", "onStoreKitStart", "0");
    }
}




-(void) addProductId:(NSString *)productId {
    [_productIdentifiers addObject:productId];
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"productsRequest....failed: %@", error.description);
    NSString *code = [NSString stringWithFormat: @"%d", (int)error.code];
   
    NSMutableString * data = [[NSMutableString alloc] init];
    [data appendString: code ];
    [data appendString:@"|"];
    
    NSString *descr = @"no_descr";
    if(error.description != nil) {
        descr = error.description;
    }
    
    [data appendString:descr];
    
    //UnitySendMessage("IOSInAppPurchaseManager", "OnStoreKitInitFailed", [ISNDataConvertor NSStringToChar:data]);
  
    
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"productsRequest....");
    NSLog(@"Total loaded products: %lu", (unsigned long)[response.products count]);
    

    
    NSMutableString * data = [[NSMutableString alloc] init];
    BOOL first = YES;
    
    
    for (SKProduct *product in response.products) {
        
        NSLog(@"%@", [product description]);
        NSLog(@"%@", [product localizedTitle]);
        NSLog(@"%@", [product localizedDescription]);
        NSLog(@"%@", [product price]);
        NSLog(@"%@", [product productIdentifier]);
        
        [_products setObject:product forKey:product.productIdentifier];
        
        
        
        if(!first) {
            [data appendString:@"|"];
        }
        
        
        first = NO;
        
        
        [data appendString:product.productIdentifier];
        [data appendString:@"|"];
        
        if( product.localizedTitle != NULL ) {
             [data appendString:product.localizedTitle];
        } else {
             [data appendString:@"null"];
        }
        [data appendString:@"|"];
        
        
        
        if( product.localizedDescription != NULL ) {
            [data appendString:product.localizedDescription];
        } else {
            [data appendString:@"null"];
        }
        [data appendString:@"|"];
        
        
        
        if( product.localizedPrice != NULL ) {
            [data appendString:product.localizedPrice];
        } else {
            [data appendString:@"null"];
        }
        [data appendString:@"|"];
        
        
        
        [data appendString:[product.price stringValue]];
        [data appendString:@"|"];
        
 
        
        NSLocale *productLocale = product.priceLocale;
      
        //  symbol and currency code
        NSString *localCurrencySymbol = [productLocale objectForKey:NSLocaleCurrencySymbol];
        NSString *currencyCode = [productLocale objectForKey:NSLocaleCurrencyCode];
        
       

        [data appendString:currencyCode];
         [data appendString:@"|"];
        
        [data appendString:localCurrencySymbol];
       

        

    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    
    //UnitySendMessage("IOSInAppPurchaseManager", "onStoreDataReceived", [ISNDataConvertor NSStringToChar:data]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
    
    
    //cocos2d::LuaEngine::getInstance()->executeGlobalFunction("hideActivityIndicator_ios_pay_load_store");
    
    [QSHelper notifiEvent2Lua: [@"evt_ios_load_store_finished" UTF8String]];
}



-(void) restorePurchases {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:_storeServer];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void) buyProduct:(NSString *)productId {
    
    
        SKProduct* selectedProduct = [_products objectForKey: productId];
        if(selectedProduct != NULL) {
            SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        } else {
//            NSMutableString * data = [[NSMutableString alloc] init];
//            
//            [data appendString:productId];
//            [data appendString:@"|"];
//            [data appendString:@"Product Not Available"];
//            [data appendString:@"|"];
//            [data appendString:@"4"];
//
//
//           NSString *str = [[data copy] autorelease];
           //UnitySendMessage("IOSInAppPurchaseManager", "onTransactionFailed", [ISNDataConvertor NSStringToChar:str]);
            
            
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"100" , @"resultCode",
                                 nil];
            
            int payResultCallBack = [[InAppPurchaseManager instance] getPlayResultCallBack];
            [QSHelper callBackCocos2dFunction:payResultCallBack Dic:dic];

        }
}
  

-(void) verifyLastPurchase:(NSString *) verificationURL {
    [_storeServer verifyLastPurchase:verificationURL];
}


- (void) CreateProductView:(int)viewId products:(NSArray *)products {
    StoreProductView* v = [[StoreProductView alloc] init];
    [v CreateView:viewId products:products];
    
    [_views setObject:v forKey:[NSNumber numberWithInt:viewId]];
}

-(void) ShowProductView:(int)viewId {
    StoreProductView *v = [_views objectForKey:[NSNumber numberWithInt:viewId]];
    if(v != nil) {
        [v Show];
    }
}

//-(void) iapppayWay:(NSString *)trandInfo {
//    ViewController* v = [[ViewController alloc]init];
//    [v iapppay:trandInfo];
//   // [ViewController iapppay:trandInfo];
//}

- (void) setPlayResultCallBack:(int) luaFuncID
{
    _payResultCallBack = luaFuncID;
}

- (int) getPlayResultCallBack
{
    return _payResultCallBack;
}
    
    
    //--------------------------------------
	//  MARKET
	//--------------------------------------
    
    void _loadStore(NSString * productsId) {
        
        //NSString* str = [ISNDataConvertor charToNSString:productsId];
        NSArray *items = [productsId componentsSeparatedByString:@","];
        
        for(NSString* s in items) {
            [[InAppPurchaseManager instance] addProductId:s];
        }
        
        [[InAppPurchaseManager instance] loadStore];
    }
    
    void _buyProduct(NSString * productId) {
        [[InAppPurchaseManager instance] buyProduct:productId];
    }
    
    void _restorePurchases() {
        [[InAppPurchaseManager instance] restorePurchases];
    }
    
    
    void _verifyLastPurchase(NSString* url) {
        [[InAppPurchaseManager instance] verifyLastPurchase:url];
    }
    
    
    void _createProductView(int viewId, NSString * productsId ) {
        //NSString* str = [ISNDataConvertor charToNSString:productsId];
        NSArray *items = [productsId componentsSeparatedByString:@","];
        
        [[InAppPurchaseManager instance] CreateProductView: viewId products:items];
    }
    
    void _showProductView(int viewId) {
        [[InAppPurchaseManager instance] ShowProductView:viewId];
    }
    
    void _ISN_RequestInAppSettingState() {
        [[InAppPurchaseManager instance] requestInAppSettingState];
    }
    
//    // 爱贝支付
//    void _iapppay(char* trandInfo) {
//        [[InAppPurchaseManager instance] iapppayWay:[ISNDataConvertor charToNSString:trandInfo]];
//    }
    
    



@end
