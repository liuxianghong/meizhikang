//
//  JSQAudioMediaItem.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//
#import <JSQMessagesViewController/JSQMessages.h>

@interface JSQAudioMediaItem : JSQMediaItem <JSQMessageMediaData, NSCopying, NSCoding>

@property (nonatomic, strong,nullable) NSURL *fileURL;
@property (strong, nonatomic,nullable) NSData *voiceData;
@property (nonatomic, assign) BOOL isReadyToPlay;
- (nonnull instancetype)initWithFileURL:(nonnull NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay;
- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (void)startPlaySound;
- (void)endPlaySound;
- (BOOL)isPlaying;

@end
