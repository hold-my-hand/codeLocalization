//
//  ViewController.m
//  codeLocalization
//
//  Created by 姜政 on 2018/2/6.
//  Copyright © 2018年 Transn. All rights reserved.
//

#import "ViewController.h"
#import "FileSystemNode.h"


@interface ViewController ()
@property (weak) IBOutlet NSBrowser *browser;
@property (strong) FileSystemNode *rootNode;
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)doMatch:(NSURL *)url{
     NSString *txt =[NSMutableString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//      self.matchL.cell.title = [[[self class] getAStringOfChineseWord:txt] componentsJoinedByString:@"\n"];
   NSArray *results =  [self getWordsOfTargetLang:@"CN" text:txt];
    if (results.count) {
        self.matchL.cell.title = [results componentsJoinedByString:@"\n"];
        [self.browser reloadColumn:0];
    }
  
}
-(NSArray *)getWordsOfTargetLang:(NSString *)tragetLang text:(NSString *)text{
    if ([tragetLang isEqualToString:@"CN"]) {
        NSString *pattern = @"@\"(.*?)\"";
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
        // 2.测试字符串
        NSArray *results = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSTextCheckingResult *result in results) {
            [array addObject:[text substringWithRange:result.range]];
        }
        return array;
    }
    return nil;
}

+ (NSArray *)getAStringOfChineseWord:(NSString *)string
{
    if ((string == nil) || [string isEqual:@""]) {
        return nil;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
 
 
    int startNum = 0;
    BOOL isStrat = NO;
    for (int i = 0; i < [string length]; i++) {
        int a = [string characterAtIndex:i];
       
        if ((a < 0x9fff) && (a >= 0x4e00)) {
            if (isStrat==NO) {
                //开始了
                isStrat = YES;
                startNum  = i;
            }else{
                
            }
        }else{
            if (isStrat) {
                [arr addObject:[string substringWithRange:NSMakeRange(startNum, i-startNum)]];
            }
            isStrat = NO;
        }
    }
    
    return arr;
}
- (IBAction)openFinder:(id)sender{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:YES];  //是否能选择文件file
    
    [panel setCanChooseDirectories:YES];  //是否能打开文件夹
    
    [panel setAllowsMultipleSelection:YES];  //是否允许多选file
    
    NSInteger finded = [panel runModal];   //获取panel的响应
    
    if (finded == NSModalResponseOK) {
        
        //   NSFileHandlingPanelCancelButton    = NSModalResponseCancel； NSFileHandlingPanelOKButton    = NSModalResponseOK,
        
        for (NSURL *url in [panel URLs]) {
            
            NSLog(@"文件路径--->%@",url);
            //同时这里可以处理你要做的事情 do something
            self.codeL.cell.title  = url.absoluteString;
            [self doMatch:url];
        }
    }
} 
- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
#pragma mark borwser delegate

- (id)rootItemForBrowser:(NSBrowser *)browser {
    
    if (self.rootNode == nil) {
        _rootNode = [[FileSystemNode alloc] initWithURL:[NSURL fileURLWithPath:NSOpenStepRootDirectory()]];
    }
    return self.rootNode;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return node.children.count;
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return [node.children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return !node.isDirectory || node.isPackage; // take into account packaged apps and documents
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    FileSystemNode *node = (FileSystemNode *)item;
    return node.displayName;
}

@end
