#import <Foundation/Foundation.h>

@protocol FSDelegate;
@protocol FSPage;

typedef NS_ENUM(uint8_t, FSEventLogLevel) {
    FSEventLogLevelAssert,
    FSEventLogLevelError,
    FSEventLogLevelWarning,
    FSEventLogLevelInfo,
    FSEventLogLevelDebug,
};

static const FSEventLogLevel FSLOG_ASSERT  = FSEventLogLevelAssert;
static const FSEventLogLevel FSLOG_ERROR   = FSEventLogLevelError;
static const FSEventLogLevel FSLOG_WARNING = FSEventLogLevelWarning;
static const FSEventLogLevel FSLOG_INFO    = FSEventLogLevelInfo;
static const FSEventLogLevel FSLOG_DEBUG   = FSEventLogLevelDebug;
static const FSEventLogLevel FS_LOGLEVEL_DEFAULT = FSEventLogLevelDebug;

typedef NSString * _Nonnull FSViewClass NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT FSViewClass const FSViewClassMask;
FOUNDATION_EXPORT FSViewClass const FSViewClassMaskWithoutConsent;
FOUNDATION_EXPORT FSViewClass const FSViewClassUnmask;
FOUNDATION_EXPORT FSViewClass const FSViewClassUnmaskWithConsent;
FOUNDATION_EXPORT FSViewClass const FSViewClassExclude;
FOUNDATION_EXPORT FSViewClass const FSViewClassExcludeWithoutConsent;

__attribute__((visibility("default")))
@interface FS : NSObject

@property (class) id<FSDelegate> _Nullable delegate;
@property (class, readonly) NSString* _Nullable currentSession;
@property (class, readonly) NSString* _Nullable currentSessionURL;

NS_ASSUME_NONNULL_BEGIN
+ (void)anonymize;
/**
 Each time a page loads from a user you can identify, you'll want to call the FS.identify() function to associate
 your own application-specific id with the active user.

 @param uid A string containing your unique identifier for the current user.
 */
+ (void)identify:(NSString *)uid;
/*!
 Each time a page loads from a user you can identify, you'll want to call the FS.identify() function to associate
 your own application-specific id with the active user.

 @discussion Limits: Sustained calls are limited to 12 calls per minute, with a burst limit of 5 calls per
 second.

 @param uid A string containing your unique identifier for the current user.

 @param userVars An NSDictionary (Dictionary if swift) with key/value pairs that provides additional
 information about your user (optional).

 @code
 // Objective-C
 NSMutableDictionary *userVars = [NSMutableDictionary dictionary];
 userVars = @{
              @"email": @"user1@example.com",
              @"displayName": @"Shopping User"
            };
 [FS identify:@"462718483" userVars:userVars]

 // Swift
 let userId = "13ff474bae77" // <- replace with your user’s Id
 let info = [
             "email": "user1@example.com",
             "displayName": "Shopping User"
            ]
 FS.identify(userId, userVars: info)
*/
+ (void)identify:(NSString *)uid userVars:(NSDictionary<NSString *, id> *)userVars;
/*!
 Each time a page loads from a user you can identify, you'll want to call the FS.identify() function to associate
 your own application-specific id with the active user.

 @discussion Limits:
 Sustained calls are limited to 12 calls per minute, with a burst limit of 5 calls per second.

 @param userVars An NSDictionary with key/value pairs that provides additional information about your
 user (optional).

 @discussion Special Fields:
 @discussion displayName | The value of displayName is displayed in the session list and on the user
 card in the app.
 @discussion email | The value of email is used to let you email the user directly from the FS app.
 The email value can also be used to retrieve users and sessions via the Get User and List Sessions HTTP
 APIs.

 @code
 // Create or use an NSDictionary || (Dictionary if swift)
 // Objective-C
 NSMutableDictionary *userVars = [NSMutableDictionary dictionary];

 userVars = @{
                 @"email": @"user1@example.com",
                 @"displayName": @"Shopping User",
                 @"pricingPlan": @"free",
                 @"totalSpent": 14.50,
                 @"requiresHelp": YES,
             };
 [FS setUserVars: userVars]

 // Swift
 let info = [
             "email": "user1@example.com",
             "displayName": "Shopping User",
             "pricingPlan": "free",
             "totalSpent": 14.50,
             "requiresHelp": true,
            ]
 FS.setUserVars( userVars: info)
*/
+ (void)setUserVars:(NSDictionary<NSString *, id> *)userVars;
+ (void)logWithLevel:(FSEventLogLevel)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);
+ (void)logWithLevel:(FSEventLogLevel)level message:(NSString *)string;
/*!
 UIViews that have been configured to "Record with user consent" in FullStory's privacy settings are recorded
 in combination with an FS.consent invocation. FS.consent(true) must be called to begin recording elements
 that have been configured to record with user consent.

 @param consented If `true`, elements configured to record with user consent in FullStory's privacy
 settings will begin recording. If false, these elements will no longer be recorded by FullStory.

 @code
 // Objective-C
 [FS consent:YES];

 // Swift
 FS.consent(true)
*/
+ (void)consent:(BOOL)consented;
/*!
 Domain-specific events recorded by FullStory add additional intelligence when you're searching across
 sessions and creating new user segments. You can define and record these events with FS.event.

 @discussion * Event names can be no longer than 250 characters.
 @discussion * The maximum size of eventProperties is 512Kb.
 @discussion * Sustained calls are limited to 30 calls per minute, with a burst limit of 10 calls per second.
 @discussion * Arrays of objects will not be indexed (arrays of strings and numbers will be indexed), with
 the exception of Order Completed events.

 @param name A string containing the name of the event.
 @param properties A NSDictionary containing additional information about the event that will be
 indexed by FullStory.

 @code
 // Create or use an NSDictionary || (Dictionary if swift )
 // Objective-C
 // Adding a product to an ecommerce cart
 NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
 eventProperties = @{
                         @"cartID" : @"130983678493",
                         @"productID" : @"798ith22928347",
                         @"sku" : @"L-100",
                         @"category" : @"Clothing"
                         @"name" : @"Button Front Cardigan",
                         @"brand" : @"Bright & Bold",
                         @"variant" : @"Blue",
                         @"priceReal" : 58.99,
                         @"quantityReal" : 1,
                         @"coupon" : @"25OFF",
                         @"position" : 3,
                         @"url" : @"https://www.example.com/product/path",
                         @"imageURL" : @"https://www.example.com/product/path.jpg"
                    };
 [FS event:@"ProductAdded" :eventProperties];

 // SaaS product subscription:
 eventProperties = @{
      @"uid": '750948353',
      @"planName": 'Professional',
      @"planPriceReal": 299,
      @"planUsers": 10,
      @"daysInTrial": 42,
      @"featurePacks": @['MAPS', 'DEV', 'DATA'],
 };
 [FS event:@"ProductAdded" :eventProperties];

 // Swift
 // Adding a product to an ecommerce cart
 eventProperties = [
                         "cartID" : "130983678493",
                         "productID" : "798ith22928347",
                         "sku" : "L-100",
                         "category" : "Clothing"
                         "name" : "Button Front Cardigan",
                         "brand" : "Bright & Bold",
                         "variant" : "Blue",
                         "priceReal" : 58.99,
                         "quantityReal" : 1,
                         "coupon" : "25OFF",
                         "position" : 3,
                         "url" : "https://www.example.com/product/path",
                         "imageURL" : "https://www.example.com/product/path.jpg"
                    ]
 FS.event(name: "Subscribed" , properties: eventProperties)

 // SaaS product subscription:
 eventProperties = [
                      "uid": '750948353',
                      "planName": 'Professional',
                      "planPriceReal": 299,
                      "planUsersInt": 10,
                      "daysInTrial_int": 42,
                      "featurePacks": ['MAPS', 'DEV', 'DATA'],
                   ]
 FS.event(name: "Subscribed" , properties: eventProperties)
*/
+ (void)event:(NSString *)name properties:(NSDictionary<NSString *, id> *)properties;
+ (void)setTagName:(UIView *)view tagName:(NSString *)tagName;
+ (void)setAttribute:(UIView *)view attributeName:(NSString *)name attributeValue:(NSString *)value;
+ (void)removeAttribute:(UIView *)view attributeName:(NSString *)name;
+ (void)addClass:(UIView *)view className:(FSViewClass)name;
+ (void)removeClass:(UIView *)view className:(FSViewClass)name;
+ (void)addClasses:(UIView *)view classNames:(NSArray<FSViewClass> *)names;
+ (void)removeClasses:(UIView *)view classNames:(NSArray<FSViewClass> *)names;
+ (void)removeAllClasses:(UIView *)view;
+ (void)shutdown;
+ (void)restart;

+ (void)mask:(UIView *)view;
+ (void)maskWithoutConsent:(UIView *)view;
+ (void)unmask:(UIView *)view;
+ (void)unmaskWithConsent:(UIView *)view;
+ (void)exclude:(UIView *)view;
+ (void)excludeWithoutConsent:(UIView *)view;

/*!
 FS.resetIdleTimer() forces the FullStory SDK out of idle mode.

 @discussion The FullStory instrumentation code automatically enters an idle mode if it does not detect
 any user input for several seconds.  In this mode, it scans the UI less frequently to conserve power and
 bandwidth.  The instrumentation exits idle mode automatically whenever it detects user input (for example,
 touch or keyboard events).  In rare cases where user interaction can't be detected automatically, the
 application can call FS.resetIdleTimer() to notify the instrumentation of the user input, and cause it to exit
 (or prevent it from entering) idle mode.
*/
+ (void)resetIdleTimer;
+ (NSString* _Nullable) currentSessionURL:(BOOL)now;

/// Returns an ``FSPage`` to represent an instance of Page in the app of type `pageName` with initial
/// properties `properties`. You MUST call ``FSPage/start`` or
/// ``FSPage/startWithPropertyUpdates:`` to signify the start of the view of the page.
///
/// If you want to call ``FSPage/end`` or ``FSPage/updateProperties:`` on the page, you
/// would typically call this method once for a given `UIViewController` or `View` instance, before
/// the view appears for the first time, to create the ``FSPage``. Subsequently, you may call
/// ``FSPage/start``, ``FSPage/end``, and ``FSPage/updateProperties:`` when a view
/// appears (`-[UIViewController viewWillAppear:]`,
/// `-[UIViewController viewDidAppear:]`, or `View.onAppear(perform:)`) or in response
/// to other events.
///
/// However, if you have no need to call those methods, you may more simply call
/// `[[FS pageWithName:@"name", properties:properties] start]` when the view appears.
///
/// - Parameters:
///     - pageName: The name that will be used for this page type by FullStory.
///     - properties: The initial properties for this page instance.
/// - Returns: An ``FSPage`` with name `pageName` and properties `properties`.
+ (id<FSPage>)pageWithName:(NSString *)pageName properties:(NSDictionary<NSString *, id> *_Nullable)properties;

/// Returns an ``FSPage`` to represent an instance of Page in the app of type
/// `pageName`. You MUST call ``FSPage/start`` to signify the start of the view of the
/// page. See ``pageWithName:properties:`` for more details.
///
/// - Parameters:
///     - pageName: The name that will be used for this page type by FullStory.
/// - Returns: An ``FSPage`` with name `pageName` and no properties.
+ (id<FSPage>)pageWithName:(NSString *)pageName;
NS_ASSUME_NONNULL_END

@end

/*! Provides metadata for screen navigation events.

 This is currently only used for UIViewController instances.
*/
__attribute__((visibility("default")))
@protocol FSScreen <NSObject>

/*! Returns the name of the receiver to use as a screen name.

 If this returns a null or empty string, the name of the receiver's class is
 used by default. If the class is a UIHostingController, the name of the hosted
 SwiftUI view type is used.

 This property is guaranteed to only be accessed on the main thread.
 */
@property (nonnull, readonly, copy) NSString *fullstoryScreenName;

@end

__attribute__((visibility("default")))
@protocol FSPage <NSObject>

/// Signals the start of a view of the page. Nested page views are not
/// supported. This will be considered the current page until another page
/// is started or ``end`` is called.
///
/// This is analogous to `viewWillAppear` in UIKit or `onAppear` in SwiftUI and
/// should typically be called there, but this may be called at any time
/// when your page boundary is not tied to a UIViewController or View
/// transition (e.g.- a single authentication View toggles between login
/// and sign up).
///
/// Subsequent calls to ``start`` will be considered distinct views of
/// the page.
///
/// If the user changes (ie- by calling ``FS/anonymize`` when a user is
/// set or by calling ``FS/identify:`` when a different non-anonymous
/// user is set), the current page will become not defined. You must call
/// ``start`` again if you would like the current page view data to be
/// set in the new user's session.
///
/// This and other page-related methods may be called while FullStory
/// capture is shut down (see ``FS/shutdown``) However, only the
/// current page data at the time ``FS/restart`` is called will be
/// captured. For example, Page A and then Page B are started while
/// shutdown, and then restart is called, Page A will not be captured, but
/// Page B will be, including any updates to Page B's properties.
- (void) start;

/// Updates the page's properties and signals the start of a view of the
/// page. This is similar to calling ``updateProperties:`` and
/// ``start`` but occurs as a single event.
///
/// See ``start`` and  ``updateProperties:`` for more information.
/// - Parameters:
///     - propertyUpdates: Updates to be made to the current page properties
- (void) startWithPropertyUpdates:(NSDictionary<NSString *, id> *_Nullable)propertyUpdates;

/// Ends the current view of the page. Calling this method is optional and
/// is only needed if you intend to leave portions of your app without
/// defined pages. This is analogous to `viewDidDisappear` in UIKIt or
/// `onDisappear` in SwiftUI and should typically be called there, if at all.
///
/// If another page has already started, calling this has no effect.
/// Otherwise, the current page will not be defined.
///
/// It is recommended to not call this method unless you intend to not have
/// defined pages for your entire app. For example, you may only wish to
/// define pages for a checkout flow within your app. You would want to call
/// end so when the user leaves the flow other portions of the app without
/// defined pages won't be treated as part of the current page.
- (void) end;

/// Updates the properties associated to this page with the key/value pairs
/// in `properties` by merging. This can be used to add additional
/// properties or update existing ones. This will not remove other
/// properties that have already been set. If called while this page is not
/// the current page (it is not currently started), these properties will
/// not be reflected until the next time ``start`` is called for this
/// page.
/// - Parameters:
///     - properties Key/value pairs to update the current page properties with
- (void) updateProperties:(NSDictionary<NSString *, id> *_Nullable)properties;
@end
