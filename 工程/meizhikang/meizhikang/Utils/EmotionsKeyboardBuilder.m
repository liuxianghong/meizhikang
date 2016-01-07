//
//  EmotionsKeyboardBuilder.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/4/12.
//
//

#import "EmotionsKeyboardBuilder.h"
#import <WUEmoticonsKeyboard/WUEmoticonsKeyboardToolsView.h>

@implementation EmotionsKeyboardBuilder
+ (WUEmoticonsKeyboard *)sharedEmoticonsKeyboard {
    static WUEmoticonsKeyboard *_sharedEmoticonsKeyboard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //create a keyboard of default size
        WUEmoticonsKeyboard *keyboard = [WUEmoticonsKeyboard keyboard];
        
//        NSArray *textKeys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"]];
        
        NSMutableArray *itemArray = [NSMutableArray array];
//        [textKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//            WUEmoticonsKeyboardKeyItem *item = [[WUEmoticonsKeyboardKeyItem alloc]init];
//            item.textToInput = obj;
//            NSString *imageString = [NSString stringWithFormat:@"emoji_%d@2x", (int)idx + 1];
//            item.image = [UIImage imageNamed:imageString];
//            [itemArray addObject:item];
//
//        }];
        NSDictionary *dic = [self emojiDic];
        for (NSString* key in dic.allKeys) {
            NSString *imageString = key;//[NSString stringWithFormat:@"emoji_%ld.png",(long)i];
            WUEmoticonsKeyboardKeyItem *item = [[WUEmoticonsKeyboardKeyItem alloc]init];
            item.textToInput = dic[key];//[NSString stringWithFormat:@"[%ld]",(long)i];
            item.image = [UIImage imageNamed:imageString];
            [itemArray addObject:item];
        }
//        //Icon keys
//        WUEmoticonsKeyboardKeyItem *loveKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
//        loveKey.image = [UIImage imageNamed:@"love"];
//        loveKey.textToInput = @"[love]";
//        
//        WUEmoticonsKeyboardKeyItem *applaudKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
//        applaudKey.image = [UIImage imageNamed:@"applaud"];
//        applaudKey.textToInput = @"[applaud]";
//        
//        WUEmoticonsKeyboardKeyItem *weicoKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
//        weicoKey.image = [UIImage imageNamed:@"weico"];
//        weicoKey.textToInput = @"[weico]";
        
        //Icon key group
        WUEmoticonsKeyboardKeyItemGroup *imageIconsGroup = [[WUEmoticonsKeyboardKeyItemGroup alloc] init];
//        imageIconsGroup.keyItems = @[loveKey,applaudKey,weicoKey];
        imageIconsGroup.keyItems = [itemArray copy];
//        UIImage *keyboardEmotionImage = [UIImage imageNamed:@"keyboard_emotion"];
//        UIImage *keyboardEmotionSelectedImage = [UIImage imageNamed:@"keyboard_emotion_selected"];
//        if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
//            keyboardEmotionImage = [keyboardEmotionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            keyboardEmotionSelectedImage = [keyboardEmotionSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        }
//        imageIconsGroup.image = keyboardEmotionImage;
//        imageIconsGroup.selectedImage = keyboardEmotionSelectedImage;
        
        //Set keyItemGroups
        keyboard.keyItemGroups = @[imageIconsGroup];
        
//        //Setup cell popup view
//        [keyboard setKeyItemGroupPressedKeyCellChangedBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, WUEmoticonsKeyboardKeyCell *fromCell, WUEmoticonsKeyboardKeyCell *toCell) {
//            [EmotionsKeyboardBuilder sharedEmotionsKeyboardKeyItemGroup:keyItemGroup pressedKeyCellChangedFromCell:fromCell toCell:toCell];
//        }];
        
        //Keyboard appearance
        
        //Custom text icons scroll background
//        if (textIconsLayout.collectionView) {
//            UIView *textGridBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [textIconsLayout collectionViewContentSize].width, [textIconsLayout collectionViewContentSize].height)];
//            textGridBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            textGridBackgroundView.backgroundColor = [UIColor lightGrayColor];
//            //            textGridBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"keyboard_grid_bg"]];
//            [textIconsLayout.collectionView addSubview:textGridBackgroundView];
//        }
//        
        //Custom utility keys
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_switch"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_del"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_switch_pressed"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateHighlighted];
//        [keyboard setImage:[UIImage imageNamed:@"del_button"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_back_button"] forButton:WUEmoticonsKeyboardButtonKeyboardSwitch state:UIControlStateNormal];
//        [keyboard setImage:[UIImage imageNamed:@"keyboard_del_pressed"] forButton:WUEmoticonsKeyboardButtonBackspace state:UIControlStateHighlighted];
        [keyboard setAttributedTitle:[[NSAttributedString alloc] initWithString:@"发送" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor darkGrayColor]}] forButton:WUEmoticonsKeyboardButtonSpace state:UIControlStateNormal];
        [keyboard setBackgroundImage:[[UIImage imageNamed:@"keyboard_space_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 23, 23)] forButton:WUEmoticonsKeyboardButtonSpace state:UIControlStateNormal];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([keyboard respondsToSelector:@selector(toolsView)]){
            WUEmoticonsKeyboardToolsView *toolsView = [keyboard performSelector:@selector(toolsView)];
            toolsView.spaceButtonTappedBlock = ^{
                if ([keyboard respondsToSelector:@selector(inputText:)])
                    [keyboard performSelector:@selector(inputText:) withObject:@"\n"];
            };
        }
#pragma clang diagnostic pop
        [keyboard setBackgroundColor:[UIColor whiteColor]];
//        
//        //Keyboard background
//        [keyboard setBackgroundImage:[[UIImage imageNamed:@"keyboard_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        
//
//        //SegmentedControl
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_normal_selected"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//        [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_selected_normal"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        
        _sharedEmoticonsKeyboard = keyboard;
    });
    return _sharedEmoticonsKeyboard;
}

//+ (void)sharedEmotionsKeyboardKeyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup
//             pressedKeyCellChangedFromCell:(WUEmoticonsKeyboardKeyCell *)fromCell
//                                    toCell:(WUEmoticonsKeyboardKeyCell *)toCell
//{
//    static WUDemoKeyboardPressedCellPopupView *pressedKeyCellPopupView;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        pressedKeyCellPopupView = [[WUDemoKeyboardPressedCellPopupView alloc] initWithFrame:CGRectMake(0, 0, 83, 110)];
//        pressedKeyCellPopupView.hidden = YES;
//        [[self sharedEmoticonsKeyboard] addSubview:pressedKeyCellPopupView];
//    });
//    
//    if ([[self sharedEmoticonsKeyboard].keyItemGroups indexOfObject:keyItemGroup] == 0) {
//        [[self sharedEmoticonsKeyboard] bringSubviewToFront:pressedKeyCellPopupView];
//        if (toCell) {
//            pressedKeyCellPopupView.keyItem = toCell.keyItem;
//            pressedKeyCellPopupView.hidden = NO;
//            CGRect frame = [[self sharedEmoticonsKeyboard] convertRect:toCell.bounds fromView:toCell];
//            pressedKeyCellPopupView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(pressedKeyCellPopupView.frame)/2);
//        }else{
//            pressedKeyCellPopupView.hidden = YES;
//        }
//    }
//}
//

+(NSDictionary *)emojiDic{
     NSDictionary *wueDic = @{@"ees.png" : @"[抠鼻]",
                             @"eci.png" : @"[恐惧]",
                             @"eex.png" : @"[左哼哼]",
                             @"ebx.png" : @"[便便]",
                             @"ecz.png" : @"[右哼哼]",
                             @"emoji_1.png" : @"[可爱]",
                             @"emoji_2.png" : @"[笑脸]",
                             @"emoji_3.png" : @"[囧]",
                             @"emoji_4.png" : @"[生气]",
                             @"emoji_5.png" : @"[鬼脸]",
                             @"emoji_6.png" : @"[花心]",
                             @"emoji_7.png" : @"[害怕]",
                             @"emoji_8.png" : @"[我汗]",
                             @"emoji_9.png" : @"[尴尬]",
                             @"emoji_10.png" : @"[哼哼]",
                             @"emoji_11.png" : @"[忧郁]",
                             @"emoji_12.png" : @"[呲牙]",
                             @"emoji_13.png" : @"[媚眼]",
                             @"emoji_14.png" : @"[累]",
                             @"emoji_15.png" : @"[苦逼]",
                             @"emoji_16.png" : @"[瞌睡]",
                             @"emoji_17.png" : @"[哎呀]",
                             @"emoji_18.png" : @"[刺瞎]",
                             @"emoji_19.png" : @"[哭]",
                             @"emoji_20.png" : @"[激动]",
                             @"emoji_21.png" : @"[难过]",
                             @"emoji_22.png" : @"[害羞]",
                             @"emoji_23.png" : @"[高兴]",
                             @"emoji_24.png" : @"[愤怒]",
                             @"emoji_25.png" : @"[亲]",
                             @"emoji_26.png" : @"[飞吻]",
                             @"emoji_27.png" : @"[得意]",
                             @"emoji_28.png" : @"[惊恐]",
                             @"emoji_29.png" : @"[口罩]",
                             @"emoji_30.png" : @"[惊讶]",
                             @"emoji_31.png" : @"[委屈]",
                             @"emoji_32.png" : @"[生病]",
                             @"emoji_33.png" : @"[红心]",
                             @"emoji_34.png" : @"[心碎]",
                             @"emoji_35.png" : @"[玫瑰]",
                             @"emoji_36.png" : @"[花]",
                             @"emoji_37.png" : @"[外星人]",
                             @"emoji_38.png" : @"[金牛座]",
                             @"emoji_39.png" : @"[双子座]",
                             @"emoji_40.png" : @"[巨蟹座]",
                             @"emoji_41.png" : @"[狮子座]",
                             @"emoji_42.png" : @"[处女座]",
                             @"emoji_43.png" : @"[天平座]",
                             @"emoji_44.png" : @"[天蝎座]",
                             @"emoji_45.png" : @"[射手座]",
                             @"emoji_46.png" : @"[摩羯座]",
                             @"emoji_47.png" : @"[水瓶座]",
                             @"emoji_48.png" : @"[白羊座]",
                             @"emoji_49.png" : @"[双鱼座]",
                             @"emoji_50.png" : @"[星座]",
                             @"emoji_51.png" : @"[男孩]",
                             @"emoji_52.png" : @"[女孩]",
                             @"emoji_53.png" : @"[嘴唇]",
                             @"emoji_54.png" : @"[爸爸]",
                             @"emoji_55.png" : @"[妈妈]",
                             @"emoji_56.png" : @"[衣服]",
                             @"emoji_57.png" : @"[皮鞋]",
                             @"emoji_58.png" : @"[照相]",
                             @"emoji_59.png" : @"[电话]",
                             @"emoji_60.png" : @"[石头]",
                             @"emoji_61.png" : @"[胜利]",
                             @"emoji_62.png" : @"[禁止]",
                             @"emoji_63.png" : @"[滑雪]",
                             @"emoji_64.png" : @"[高尔夫]",
                             @"emoji_65.png" : @"[网球]",
                             @"emoji_66.png" : @"[棒球]",
                             @"emoji_67.png" : @"[冲浪]",
                             @"emoji_68.png" : @"[足球]",
                             @"emoji_69.png" : @"[小鱼]",
                             @"emoji_70.png" : @"[问号]",
                             @"emoji_71.png" : @"[叹号]",
                             @"emoji_179.png" : @"[顶]",
                             @"emoji_180.png" : @"[写字]",
                             @"emoji_181.png" : @"[衬衫]",
                             @"emoji_182.png" : @"[小花]",
                             @"emoji_183.png" : @"[郁金香]",
                             @"emoji_184.png" : @"[向日葵]",
                             @"emoji_185.png" : @"[鲜花]",
                             @"emoji_186.png" : @"[椰树]",
                             @"emoji_187.png" : @"[仙人掌]",
                             @"emoji_188.png" : @"[气球]",
                             @"emoji_189.png" : @"[炸弹]",
                             @"emoji_190.png" : @"[喝彩]",
                             @"emoji_191.png" : @"[剪子]",
                             @"emoji_192.png" : @"[蝴蝶结]",
                             @"emoji_193.png" : @"[机密]",
                             @"emoji_194.png" : @"[铃声]",
                             @"emoji_195.png" : @"[女帽]",
                             @"emoji_196.png" : @"[裙子]",
                             @"emoji_197.png" : @"[理发店]",
                             @"emoji_198.png" : @"[和服]",
                             @"emoji_199.png" : @"[比基尼]",
                             @"emoji_200.png" : @"[拎包]",
                             @"emoji_201.png" : @"[拍摄]",
                             @"emoji_202.png" : @"[铃铛]",
                             @"emoji_203.png" : @"[音乐]",
                             @"emoji_204.png" : @"[心星]",
                             @"emoji_205.png" : @"[粉心]",
                             @"emoji_206.png" : @"[丘比特]",
                             @"emoji_207.png" : @"[吹气]",
                             @"emoji_208.png" : @"[口水]",
                             @"emoji_209.png" : @"[对]",
                             @"emoji_210.png" : @"[错]",
                             @"emoji_211.png" : @"[绿茶]",
                             @"emoji_212.png" : @"[面包]",
                             @"emoji_213.png" : @"[面条]",
                             @"emoji_214.png" : @"[咖喱饭]",
                             @"emoji_215.png" : @"[饭团]",
                             @"emoji_216.png" : @"[麻辣烫]",
                             @"emoji_217.png" : @"[寿司]",
                             @"emoji_218.png" : @"[苹果]",
                             @"emoji_219.png" : @"[橙子]",
                             @"emoji_220.png" : @"[草莓]",
                             @"emoji_221.png" : @"[西瓜]",
                             @"emoji_222.png" : @"[柿子]",
                             @"emoji_223.png" : @"[眼睛]",
                             @"emoji_224.png" : @"[好的]"
                             };
    return wueDic;
}


@end
