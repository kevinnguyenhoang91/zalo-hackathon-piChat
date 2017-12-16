//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Brian Lambert.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  BubbleChat
//  TSNAppContext.m
//

#import <pthread.h>
#import "TSNAtomicFlag.h"
#import "TSNAppContext.h"
#import "TSNPeerBluetooth.h"
#import "TSNLocationContext.h"
#import "TSNPeerStatus.h"

// External definitions.
NSString * const TSNLocationUpdatedNotification = @"TSNLocationUpdated";
NSString * const TSNPeersUpdatedNotification    = @"TSNPeersUpdated";
NSString * const TSNPeerEnteredNotification     = @"TSNPeerEntered";
NSString * const TSNPeerExitedNotification      = @"TSNPeerExited";
NSString * const TSNPeerStatusNotification      = @"TSNPeerStatus";

// TSNAppContext (TSNPeerBluetoothDelegate) interface.
@interface TSNAppContext (TSNPeerBluetoothDelegate) <TSNPeerBluetoothDelegate>
@end

// TSNAppContext (TSNLocationContextDelegate) interface.
@interface TSNAppContext (TSNLocationContextDelegate) <TSNLocationContextDelegate>
@end

// TSNAppContext (Internal) interface.
@interface TSNAppContext (Internal)

// Class initializer.
- (instancetype)init;

@end

// TSNAppContext implementation.
@implementation TSNAppContext
{
@private
    // The enabled atomic flag.
    TSNAtomicFlag * _atomicFlagEnabled;

    // Peer Bluetooth.
    TSNPeerBluetooth * _peerBluetooth;
    
    // The location context.
    TSNLocationContext * _locationContext;
    
    // The mutex used to protect access to things below.
    pthread_mutex_t _mutex;

    // The location.
    CLLocation * _location;
    
    // The peers dictionary.
    NSMutableDictionary * _peers;
}

// Singleton.
+ (instancetype)singleton
{
    // Singleton instance.
    static TSNAppContext * appContext = nil;
    
    // If unallocated, allocate.
    if (!appContext)
    {
        // Allocator.
        void (^allocator)() = ^
        {
            appContext = [[TSNAppContext alloc] init];
        };
        
        // Dispatch allocator once.
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, allocator);
    }
    
    // Done.
    return appContext;
}

// Starts communications.
- (void)startCommunications
{
    if ([_atomicFlagEnabled trySet])
    {
        [_peerBluetooth start];
        [_locationContext start];
    }
}

// Stops communications.
- (void)stopCommunications
{
    if ([_atomicFlagEnabled tryClear])
    {
        [_peerBluetooth stop];
        [_locationContext stop];
    }
}

- (NSArray *)peers
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    NSArray * peers = [_peers allValues];
    
    // Unlock.
    pthread_mutex_unlock(&_mutex);

    // Return the peers.
    return peers;
}

// Updates status.
- (void)updateStatus:(NSString *)status
{
    [_peerBluetooth updateStatus:status];
}

@end

// TSNAppContext (TSNPeerBluetoothDelegate) implementation.
@implementation TSNAppContext (TSNPeerBluetoothDelegate)

// Notifies the delegate that a peer was connected.
- (void)peerBluetooth:(TSNPeerBluetooth *)peerBluetooth
didConnectPeerIdentifier:(NSUUID *)peerIdentifier
             peerName:(NSString *)peerName
         peerLocation:(CLLocation *)peerLocation
{
    // Allocate and initialize the peer.
    TSNPeer * peer = [[TSNPeer alloc] initWithIdentifier:[peerIdentifier UUIDString]
                                                    name:peerName
                                                location:peerLocation
                                                distance:[_location distanceFromLocation:peerLocation]];
    
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Set the peer in the peers dictionary.
    [_peers setObject:peer
               forKey:peerIdentifier];
    
    // Unlock.
    pthread_mutex_unlock(&_mutex);
    
    // Post notifications.
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:TSNPeerEnteredNotification
                                      object:peer];
    [notificationCenter postNotificationName:TSNPeersUpdatedNotification
                                      object:nil];

    // If the application is not active, post a local notification.
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        UILocalNotification * localNotification = [[UILocalNotification alloc] init];
        [localNotification setFireDate:[[NSDate alloc] init]];
        [localNotification setAlertBody:[NSString stringWithFormat:@"%@: Entered YALO", [peer name]]];
        [localNotification setSoundName:UILocalNotificationDefaultSoundName];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

// Notifies the delegate that a peer was disconnected.
- (void)peerBluetooth:(TSNPeerBluetooth *)peerBluetooth
didDisconnectPeerIdentifier:(NSUUID *)peerIdentifier
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Find the peer.
    TSNPeer * peer = _peers[peerIdentifier];
    if (!peer)
    {
        pthread_mutex_unlock(&_mutex);
        return;
    }
    
    // Remove the peer.
    [_peers removeObjectForKey:peerIdentifier];

    // Unlock.
    pthread_mutex_unlock(&_mutex);
    
    // Post notifications.
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:TSNPeerExitedNotification
                                      object:peer];
    [notificationCenter postNotificationName:TSNPeersUpdatedNotification
                                      object:nil];
    
    // If the application is not active, post a local notification.
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        UILocalNotification * localNotification = [[UILocalNotification alloc] init];
        [localNotification setFireDate:[[NSDate alloc] init]];
        [localNotification setAlertBody:[NSString stringWithFormat:@"%@: Exited YALO", [peer name]]];
        [localNotification setSoundName:UILocalNotificationDefaultSoundName];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

// Notifies the delegate that a peer updated its location.
- (void)peerBluetooth:(TSNPeerBluetooth *)peerBluetooth
didReceivePeerLocation:(CLLocation *)peerLocation
   fromPeerIdentifier:(NSUUID *)peerIdentifier
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Find the peer. If the peer was not found, ignore the update.
    TSNPeer * peer = _peers[peerIdentifier];
    if (!peer)
    {
        pthread_mutex_unlock(&_mutex);
        return;
    }
    
    // Update the peer's location and distance.
    [peer setLocation:peerLocation];
    [peer setDisance:[peerLocation distanceFromLocation:_location]];
    [peer setLastUpdated:[[NSDate alloc] init]];
    
    // Unlock.
    pthread_mutex_unlock(&_mutex);
    
    // Post notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:TSNPeersUpdatedNotification
                                                        object:nil];
}

// Notifies the delegate that a peer status was received.
- (void)peerBluetooth:(TSNPeerBluetooth *)peerBluetooth
 didReceivePeerStatus:(NSString *)peerStatus
   fromPeerIdentifier:(NSUUID *)peerIdentifier
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Find the peer.
    TSNPeer * peer = _peers[peerIdentifier];

    // Unlock.
    pthread_mutex_unlock(&_mutex);

    // If the peer was not found, ignore the update.
    if (!peer)
    {
        return;
    }

    // Post notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:TSNPeerStatusNotification
                                                        object:[[TSNPeerStatus alloc] initWithPeer:peer
                                                                                            status:peerStatus]];

    // If the application is not active, post a local notification.
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        UILocalNotification * localNotification = [[UILocalNotification alloc] init];
        [localNotification setFireDate:[[NSDate alloc] init]];
        [localNotification setAlertBody:[NSString stringWithFormat:@"%@: %@", [peer name], peerStatus]];
        [localNotification setSoundName:UILocalNotificationDefaultSoundName];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

@end

// TSNAppContext (TSNLocationContextDelegate) implementation.
@implementation TSNAppContext (TSNLocationContextDelegate)

// Notifies the delegate that the location was updated.
- (void)locationContext:(TSNLocationContext *)locationContext
      didUpdateLocation:(CLLocation *)location
{
    // Lock.
    pthread_mutex_lock(&_mutex);
    
    // Update the location.
    _location = location;
    
    // Unlock.
    pthread_mutex_unlock(&_mutex);
    
    // Update our location in the peer Bluetooth context to share it with peers.
    [_peerBluetooth updateLocation:location];

    // Post the TSNLocationUpdatedNotification so the rest of the app knows about the location update.
    [[NSNotificationCenter defaultCenter] postNotificationName:TSNLocationUpdatedNotification
                                                        object:location];
}

@end

// TSNAppContext (Internal) implementation.
@implementation TSNAppContext (Internal)

// Class initializer.
- (instancetype)init
{
    // Initialize superclass.
    self = [super init];
    
    // Handle errors.
    if (!self)
    {
        return nil;
    }
    
    // Intialize.
    _atomicFlagEnabled = [[TSNAtomicFlag alloc] init];
    pthread_mutex_init(&_mutex, NULL);
    _peers = [[NSMutableDictionary alloc] init];
    
    // Allocate and initialize the service type.
    NSUUID * serviceType = [[NSUUID alloc] initWithUUIDString:@"B206EE5D-17EE-40C1-92BA-462A038A33D2"];
    
    // Static declarations.
    static NSString * const PEER_IDENTIFIER_KEY = @"PeerIdentifierKey";
        
    // Obtain user defaults and see if we have a serialized peer identifier. If we do,
    // deserialize it. If not, make one and serialize it for later use.
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * peerIdentifierData = [userDefaults dataForKey:PEER_IDENTIFIER_KEY];
    if (!peerIdentifierData)
    {
        // Create a new peer identifier.
        UInt8 uuid[16];
        [[NSUUID UUID] getUUIDBytes:uuid];
        peerIdentifierData = [NSData dataWithBytes:uuid
                                            length:sizeof(uuid)];
        
        // Save the peer identifier in user defaults.
        [userDefaults setValue:peerIdentifierData
                        forKey:PEER_IDENTIFIER_KEY];
        [userDefaults synchronize];
    }
    NSUUID * peerIdentifier = [[NSUUID alloc] initWithUUIDBytes:[peerIdentifierData bytes]];
    
    // Allocate and initialize the peer Bluetooth context.
    _peerBluetooth = [[TSNPeerBluetooth alloc] initWithServiceType:serviceType
                                                    peerIdentifier:peerIdentifier
                                                          peerName:[[UIDevice currentDevice] name]];
    [_peerBluetooth setDelegate:(id<TSNPeerBluetoothDelegate>)self];
    
    // Allocate and initialize the location context.
    _locationContext = [[TSNLocationContext alloc] init];
    [_locationContext setDelegate:(id<TSNLocationContextDelegate>)self];

    // Done.
    return self;
}

@end
