//
//  JSQAudioMediaItem.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/3.
//
//

#import "JSQAudioMediaItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"

@interface JSQAudioMediaItem ()
@property (strong, nonatomic) UIView *cachedAudioImageView;
@property (strong, nonatomic) UIImageView *voiceStateView;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation JSQAudioMediaItem

- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _isReadyToPlay = isReadyToPlay;
        _cachedAudioImageView = nil;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self){
        _fileURL = nil;
        _voiceData = data;
        _isReadyToPlay = YES;
        _cachedAudioImageView = nil;
    }
    return self;
}

- (void)dealloc
{
    _fileURL = nil;
    _cachedAudioImageView = nil;
}
#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedAudioImageView = nil;
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedAudioImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedAudioImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if ((self.fileURL == nil && self.voiceData == nil)|| !self.isReadyToPlay) {
        return nil;
    }
    
    if (self.cachedAudioImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIView *imageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        if (self.appliesMediaViewMaskAsOutgoing) {
            imageView.backgroundColor = [UIColor colorWithRed:27.0/255.0 green:222.0/255.0 blue:192.0/255.0 alpha:1.0];
            _voiceStateView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_animation_white3"]];
            [_voiceStateView setFrame:CGRectMake(20, 12, 20, 20)];
            _voiceStateView.animationImages = @[[UIImage imageNamed:@"chat_animation_white1"],
                                                [UIImage imageNamed:@"chat_animation_white2"],
                                                [UIImage imageNamed:@"chat_animation_white3"]];
//            _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 50, 22)];
//            _timeLabel.textAlignment = NSTextAlignmentRight;
//            [_timeLabel setTextColor:[UIColor blackColor]];
        }
        else{
            imageView.backgroundColor = [UIColor whiteColor];
            _voiceStateView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_animation3"]];
            [_voiceStateView setFrame:CGRectMake(110, 12, 20, 20)];
            _voiceStateView.animationImages = @[[UIImage imageNamed:@"chat_animation1"],
                                                [UIImage imageNamed:@"chat_animation2"],
                                                [UIImage imageNamed:@"chat_animation3"]];
//            _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 10, 50, 22)];
//            _timeLabel.textAlignment = NSTextAlignmentLeft;
//            [_timeLabel setTextColor:[UIColor whiteColor]];
        }
        _voiceStateView.animationDuration = 1;
        _voiceStateView.animationRepeatCount = 0;
        [imageView addSubview:_voiceStateView];
        
//        [_timeLabel setFont:[UIFont systemFontOfSize:14.0f]];
//        [_timeLabel setText:@"60''"];
//        [imageView addSubview:_timeLabel];
        //        [_voiceStateView startAnimating];
//                if message.senderId == self.senderId{
//                    image = UIImage(named: "蓝对话框.png")
//                }else{
//                    image = UIImage(named: "白对话框.png")
//                }
//                let factory = JSQMessagesBubbleImageFactory(bubbleImage: image, capInsets: UIEdgeInsetsMake(7, 12, 25, 12))
//                let mask = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: factory)
//                mask.applyOutgoingBubbleImageMaskToMediaView(imageView)
        UIImage *tmp = nil;
        if (self.appliesMediaViewMaskAsOutgoing){
            tmp = [[UIImage imageNamed:@"蓝对话框.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 12, 25, 12) resizingMode:UIImageResizingModeStretch];
        }else{
            tmp = [[UIImage imageNamed:@"白对话框.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 12, 25, 12) resizingMode:UIImageResizingModeStretch];
        }
        JSQMessagesBubbleImage *bubbleImage = [[JSQMessagesBubbleImage alloc] initWithMessageBubbleImage:tmp highlightedImage:tmp];
        UIImage *image = [bubbleImage messageBubbleImage];
        UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
        imageViewMask.frame = CGRectInset(imageView.frame, 2.0f, 2.0f);
        imageView.layer.mask = imageViewMask.layer;
        self.cachedAudioImageView = imageView;
    }
    
    return self.cachedAudioImageView;
}
- (CGSize)mediaViewDisplaySize {
    return CGSizeMake(150, 44);
}

#pragma mark - Actions
- (void)startPlaySound {
    [_voiceStateView startAnimating];
}
- (void)endPlaySound {
    [_voiceStateView stopAnimating];
}
- (BOOL)isPlaying {
    return [_voiceStateView isAnimating];
}


@end
