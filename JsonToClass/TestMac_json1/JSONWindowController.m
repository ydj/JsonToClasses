//
//  JSONWindowController.m
//  AutomaticCoder
//

//

#import "JSONWindowController.h"


#define kItem @"Item"
#define kList @"List"

@interface JSONWindowController ()

@end

@implementation JSONWindowController
@synthesize jsonContent;
@synthesize jsonName;
@synthesize preName;
@synthesize jsonURL;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    array = [[NSArrayController alloc] init];
}


-(NSArray *)getArray:(NSArray *)temp
{

    NSMutableArray * result=[NSMutableArray array];
    NSMutableArray * _set=[NSMutableArray array];
    for (id item in temp) {
        if ([self type:item]==kDictionary) {
            [_set addObject:item];
        }
    }
    NSMutableArray * theSet=[NSMutableArray array];
    if ([_set count]>0) {
        [theSet addObject:[_set objectAtIndex:0]];
    }
    
    for (NSDictionary * dic in _set ) {
        
        for (NSDictionary * nDic in theSet) {
            
            if (![[nDic allKeys] isEqualToArray:[dic allKeys]]) {
                if ([[nDic allKeys] count]<[[dic allKeys] count]) {
                    [theSet insertObject:dic atIndex:[theSet indexOfObject:nDic]];
                }
                else{
                    [theSet addObject:dic];
                }
            }
            
        }
        
    }
    
    
    [result addObjectsFromArray:theSet];
    
    return result;
    
}


-(void)getDataFromIt:(id)json withName:(NSString *)name
{

    //准备模板
    NSMutableString *templateH =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"zx1"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    NSMutableString *templateM =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"zx2"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    
    
    //.h
    //name
    //property
    NSMutableString *proterty = [NSMutableString string];
    NSMutableString *import = [NSMutableString string];
    NSMutableString * deallocString=[NSMutableString string];
    
    if ([self type:json]==kDictionary ||[[json className] isEqual:@"__NSDictionaryI"]||[[json className] isEqual:@"__NSDictionaryM"]) {
       
         for(NSString *key in [json allKeys])
         {
           JsonValueType type = [self type:[json objectForKey:key]];

             switch (type) {
                 case kString:
                 case kNumber:
                 {
                     [proterty appendFormat:@"@property (nonatomic,strong)%@ *%@;\n",[self typeName:type],key];
                     [deallocString appendFormat:@"[_%@ release];\n",key];

                     break;
                 }
                case kArray:
                 {
                     [proterty appendFormat:@"@property (nonatomic,strong)NSMutableArray *%@;\n",key];
                     [deallocString appendFormat:@"[_%@ release];\n",key];
                     
                     NSMutableString * tempImport=(NSMutableString *)[self uppercaseFirstChar:key];
                     tempImport=(NSMutableString *)[tempImport stringByReplacingOccurrencesOfString:kList withString:@""];
                     tempImport=(NSMutableString *)[tempImport stringByReplacingOccurrencesOfString:kItem withString:@""];
                     [tempImport appendFormat:kItem];
                     
                     [import appendFormat:@"#import \"%@.h\"\n",tempImport];
                 
                     
                     
                     NSArray * temp=[json objectForKey:key];
                     if ([temp count]>0) {
                         NSArray * _setArray=[self getArray:temp];
                       [self getDataFromIt:_setArray withName:[NSString stringWithFormat:@"%@",tempImport]];
                      }
                     
                     break;
                 }
                case kDictionary:
                 {
                     [proterty appendFormat:@"@property (nonatomic,strong) %@ *%@;\n",[self uppercaseFirstChar:key],key];
                     [deallocString appendFormat:@"[_%@ release];\n",key];

                     [import appendFormat:@"#import \"%@.h\"\n",[self uppercaseFirstChar:key]];
                     
                     [self getDataFromIt:[json objectForKey:key] withName:[NSString stringWithFormat:@"%@",[self uppercaseFirstChar:key]]];
                     
                     break;
                 }
                 case kBool:
                 {  [proterty appendFormat:@"@property (nonatomic,assign) %@ %@;\n",[self typeName:type],key];
                     break;
                 }
                 default:
                     break;
             }
             
             
         }
        
        
        [templateH replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        [templateH replaceOccurrencesOfString:@"#import#"
                                   withString:import
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        [templateH replaceOccurrencesOfString:@"#property#"
                                   withString:proterty
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        
        [templateM replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        
        NSMutableString *config = [NSMutableString string];
        NSMutableString *encode = [NSMutableString string];
        NSMutableString *decode = [NSMutableString string];
        NSMutableString *description = [NSMutableString string];
        NSDictionary *list =  @{
        @"config":config,
        @"encode":encode,
        @"decode":decode,
        @"description":description,
        @"dealloc":deallocString
        };
        
        for(NSString *key in [json allKeys])
        {
            JsonValueType type = [self type:[json objectForKey:key]];
            
            switch (type) {
                case kString:
                case kNumber:
                {
                    [config appendFormat:@"self.%@  = [json objectForKey:@\"%@\"];\n ",key,key];
                    
                    [encode appendFormat:@"[aCoder encodeObject:self.%@ forKey:@\"jingyou_%@\"];\n",key,key];
                    [decode appendFormat:@"self.%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@ : %%@\\n\",self.%@];\n",key,key];
                    
                    break;
                }
                case kArray:
                {
                    NSMutableString * tempImport=(NSMutableString *)[self uppercaseFirstChar:key];
                    tempImport=(NSMutableString *)[tempImport stringByReplacingOccurrencesOfString:kList withString:@""];
                    tempImport=(NSMutableString *)[tempImport stringByReplacingOccurrencesOfString:kItem withString:@""];
                    [tempImport appendFormat:kItem];
                    [config appendFormat:@"self.%@ = [NSMutableArray array];\n",key];
                    [config appendFormat:@"for(id item in [json objectForKey:@\"%@\"])\n",key];
                    [config appendString:@"{\n"];
                    [config appendString:@"if ([item isKindOfClass:[NSDictionary class]])"];
                    [config appendString:@"{\n"];
                    [config appendFormat:@"[self.%@ addObject:[[[%@ alloc] initWithJson:item]autorelease]];\n",key,tempImport];
                    [config appendString:@"}\n"];
                    [config appendString:@"else"];
                    [config appendString:@"{\n"];
                    [config appendFormat:@"[self.%@ addObject:item];\n",key];
                    [config appendString:@"}\n"];
                    [config appendString:@"}\n"];
                    
                    
                    [encode appendFormat:@"[aCoder encodeObject:self.%@ forKey:@\"jingyou_%@\"];\n",key,key];
                    [decode appendFormat:@"self.%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@ : %%@\\n\",self.%@];\n",key,key];
                    
                    
                    
                    break;
                }
                case kDictionary:
                {
                    [config appendFormat:@"self.%@  = [[[%@ alloc] initWithJson:[json objectForKey:@\"%@\"]]autorelease];\n ",key,[self uppercaseFirstChar:key],key];
                    [encode appendFormat:@"[aCoder encodeObject:self.%@ forKey:@\"jingyou_%@\"];\n",key,key];
                    [decode appendFormat:@"self.%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@ : %%@\\n\",self.%@];\n",key,key];
                    
                    break;
                }
                case kBool:
                {
                    [config appendFormat:@"self.%@ = [[json objectForKey:@\"%@\"]boolValue];\n ",key,key];
                    
                    
                    [encode appendFormat:@"[aCoder encodeBool:self.%@ forKey:@\"jingyou_%@\"];\n",key,key];
                    [decode appendFormat:@"self.%@ = [aDecoder decodeBoolForKey:@\"jingyou_%@\"];\n",key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@ : %%@\\n\",self.%@?@\"yes\":@\"no\"];\n",key,key];

                    break;
                }
                default:
                    break;
            }
            
            
        }

        
        for(NSString *key in [list allKeys])
        {
            [templateM replaceOccurrencesOfString:[NSString stringWithFormat:@"#%@#",key]
                                       withString:[list objectForKey:key]
                                          options:NSCaseInsensitiveSearch
                                            range:NSMakeRange(0, templateM.length)];
        }
        
        
        //写文件
        NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.h",path,name]);
        [templateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",path,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        [templateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",path,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        
        
        
        
    }//字典
    else if([self type:json]==kArray ||[[json className] isEqual:@"__NSArrayM"]||[[json className] isEqual:@"__NSArrayI"]){//数组
    
        NSDictionary * lastDic=[(NSArray *)json lastObject];
        NSString * tempName=[self uppercaseFirstChar:name];
        tempName=[tempName stringByReplacingOccurrencesOfString:kItem withString:@""];
        [self getDataFromIt:lastDic withName:[NSString stringWithFormat:@"%@%@",tempName,kItem]];
    }
    
}


-(void)generateClass:(NSString *)name forDic:(NSDictionary *)json
{
    //准备模板
    NSMutableString *templateH =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"zx1"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    NSMutableString *templateM =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"zx2"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    
    
        //.h
        //name
        //property
        NSMutableString *proterty = [NSMutableString string];
        NSMutableString *import = [NSMutableString string];
        NSMutableString * deallocString=[NSMutableString string];
        
        
        
        for(NSString *key in [json allKeys])
        {
            JsonValueType type = [self type:[json objectForKey:key]];
            switch (type) {
                case kString:
                case kNumber:
                {  [proterty appendFormat:@"@property (nonatomic,strong) %@ *%@%@;\n",[self typeName:type],preName.stringValue,key];
                    [deallocString appendFormat:@"[_%@%@ release];\n",preName.stringValue,key];
                    break;}
                case kArray:
                {
                    // if([self isDataArray:[json objectForKey:key]])
                    if ([self isStringDataArray:[json objectForKey:key]])
                    {
                        [proterty appendFormat:@"@property (nonatomic,strong) NSMutableArray *%@%@;\n",preName.stringValue,key];
                        [deallocString appendFormat:@"[_%@%@ release];\n",preName.stringValue,key];
                        
                        [import appendFormat:@"#import \"%@.h\"\n",[self uppercaseFirstChar:key]];
                      
                            [self generateClass:[NSString stringWithFormat:@"%@",[self uppercaseFirstChar:key]] forDic:[[json objectForKey:key]objectAtIndex:0]];
                        
                    }
                }
                    break;
                case kDictionary:
                    [proterty appendFormat:@"@property (nonatomic,strong) %@ *%@%@;\n",[self uppercaseFirstChar:key],preName.stringValue,key];
                    [deallocString appendFormat:@"[_%@%@ release];\n",preName.stringValue,key];
                    
                    [import appendFormat:@"#import \"%@.h\"\n",[self uppercaseFirstChar:key]];
                    
                        [self generateClass:[NSString stringWithFormat:@"%@",[self uppercaseFirstChar:key]] forDic:[json objectForKey:key]];
                
                    break;
                case kBool:
                    [proterty appendFormat:@"@property (nonatomic,assign) %@ %@%@;\n",[self typeName:type],preName.stringValue,key];
                    [deallocString appendFormat:@"[_%@%@ release];\n",preName.stringValue,key];
                    
                    break;
                default:
                    break;
            }
        }
        
        [templateH replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        [templateH replaceOccurrencesOfString:@"#import#"
                                   withString:import
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        [templateH replaceOccurrencesOfString:@"#property#"
                                   withString:proterty
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        //.m
        //NSCoding
        //name
        [templateM replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        
        NSMutableString *config = [NSMutableString string];
        NSMutableString *encode = [NSMutableString string];
        NSMutableString *decode = [NSMutableString string];
        NSMutableString *description = [NSMutableString string];
        
        NSDictionary *list =  @{
        @"config":config,
        @"encode":encode,
        @"decode":decode,
        @"description":description,
        @"dealloc":deallocString
        };
        
        
        for(NSString *key in [json allKeys])
        {
            JsonValueType type = [self type:[json objectForKey:key]];
            switch (type) {
                case kString:
                case kNumber:
                    [config appendFormat:@"self.%@%@  = [json objectForKey:@\"%@\"];\n ",preName.stringValue,key,key];
                    [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"jingyou_%@\"];\n",preName.stringValue,key,key];
                    [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",preName.stringValue,key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",preName.stringValue,key,preName.stringValue,key];
                    break;
                case kArray:
                {
                    /*if([self isDataArray:[json objectForKey:key]])
                     {
                     [config appendFormat:@"self.%@%@ = [NSMutableArray array];\n",preName.stringValue,key];
                     [config appendFormat:@"for(NSDictionary *item in [json objectForKey:@\"%@\"])\n",key];
                     [config appendString:@"{\n"];
                     [config appendFormat:@"[self.%@%@ addObject:[[%@ alloc] initWithJson:item]];\n",preName.stringValue,key,[self uppercaseFirstChar:key]];
                     [config appendString:@"}\n"];
                     [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"jingyou_%@\"];\n",preName.stringValue,key,key];
                     [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",preName.stringValue,key,key];
                     [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",preName.stringValue,key,preName.stringValue,key];
                     }*/
                    
                    
                    if ([self isStringDataArray:[json objectForKey:key]]) {
                        
                        [config appendFormat:@"self.%@%@ = [NSMutableArray array];\n",preName.stringValue,key];
                        [config appendFormat:@"for(id item in [json objectForKey:@\"%@\"])\n",key];
                        [config appendString:@"{\n"];
                        [config appendString:@"if ([item isKindOfClass:[NSDictionary class]])"];
                        [config appendString:@"{\n"];
                        [config appendFormat:@"[self.%@%@ addObject:[[%@ alloc] initWithJson:item]];\n",preName.stringValue,key,[self uppercaseFirstChar:key]];
                        [config appendString:@"}\n"];
                        [config appendString:@"else if (item)"];
                        [config appendString:@"{\n"];
                        [config appendFormat:@"[self.%@%@ addObject:item];\n",preName.stringValue,key];
                        [config appendString:@"}\n"];
                        [config appendString:@"}\n"];
                        
                        [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"jingyou_%@\"];\n",preName.stringValue,key,key];
                        [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",preName.stringValue,key,key];
                        [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",preName.stringValue,key,preName.stringValue,key];
                        
                    }
                    
                    
                }
                    break;
                case kDictionary:
                    [config appendFormat:@"self.%@%@  = [[%@ alloc] initWithJson:[json objectForKey:@\"%@\"]];\n ",preName.stringValue,key,[self uppercaseFirstChar:key],key];
                    [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"jingyou_%@\"];\n",preName.stringValue,key,key];
                    [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"jingyou_%@\"];\n ",preName.stringValue,key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",preName.stringValue,key,preName.stringValue,key];
                    
                    break;
                case kBool:
                    [config appendFormat:@"self.%@%@ = [[json objectForKey:@\"%@\"]boolValue];\n ",preName.stringValue,key,key];
                    [encode appendFormat:@"[aCoder encodeBool:self.%@%@ forKey:@\"jingyou_%@\"];\n",preName.stringValue,key,key];
                    [decode appendFormat:@"self.%@%@ = [aDecoder decodeBoolForKey:@\"jingyou_%@\"];\n",preName.stringValue,key,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@?@\"yes\":@\"no\"];\n",preName.stringValue,key,preName.stringValue,key];
                    break;
                default:
                    break;
            }
        }
        
        //修改模板
        for(NSString *key in [list allKeys])
        {
            [templateM replaceOccurrencesOfString:[NSString stringWithFormat:@"#%@#",key]
                                       withString:[list objectForKey:key]
                                          options:NSCaseInsensitiveSearch
                                            range:NSMakeRange(0, templateM.length)];
        }
        
        
        //写文件
        NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.h",path,name]);
        [templateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",path,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        [templateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",path,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];

  //  }
    
     
}



- (IBAction)useTestURL:(id)sender {
    jsonURL.stringValue = @"http://zxapi.sinaapp.com";
}

- (IBAction)getJSONWithURL:(id)sender {
    
    NSString *str = [jsonURL.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                        returningResponse:nil
                                                                    error:nil];
    
    NSDictionary *json = [data objectFromJSONData];
    if(json != nil)
    jsonContent.string = [json JSONStringWithOptions:JKSerializeOptionPretty error:nil];
}

-(void)generateProperty:(NSDictionary *)json withName:(NSString *)className;
{
    for(NSString *key in [json allKeys])
    {
        JsonValueType type = [self type:[json objectForKey:key]];
        switch (type) {
            case kString:
            {
                NSDictionary *dic =
                @{
                @"jsonKey":key,
                @"jsonType":@"string",
                @"classKey":[NSString stringWithFormat:@"%@%@",preName.stringValue,key],
                @"classType":@"NSString",
                @"className":className
                };
                [array addObject:[dic mutableCopy]];
            }
                break;
            case kNumber:
            {
                NSDictionary *dic =
                @{
                @"jsonKey":key,
                @"jsonType":@"number",
                @"classKey":[NSString stringWithFormat:@"%@%@",preName.stringValue,key],
                @"classType":@"NSNumber",
                @"className":className

                };
                [array addObject:[dic mutableCopy]];
            }
                break;
            case kArray:
            {
                {
                    NSDictionary *dic =
                    @{
                    @"jsonKey":key,
                    @"jsonType":@"array",
                    @"classKey":[NSString stringWithFormat:@"%@%@",preName.stringValue,key],
                    @"classType":[NSString stringWithFormat:@"NSArray(%@)",[self uppercaseFirstChar:key]],
                    @"className":className
                    };
                    [array addObject:[dic mutableCopy]];
                    if([self isDataArray:[json objectForKey:key]])
                    {
                        [self generateProperty:[[json objectForKey:key] objectAtIndex:0]
                                      withName:[self uppercaseFirstChar:key]];
                    }
                }
                break;
            }
                break;
            case kDictionary:
            {
                NSDictionary *dic =
                @{
                @"jsonKey":[self lowercaseFirstChar:key],
                @"jsonType":@"object",
                @"classKey":[NSString stringWithFormat:@"%@%@",preName.stringValue,key],
                @"classType":[self uppercaseFirstChar:key],
                @"className":className
                };
                [array addObject:[dic mutableCopy]];
                [self generateProperty:[json objectForKey:key]
                              withName:[self uppercaseFirstChar:key]];
            }
                break;
            case kBool:
            {
                NSDictionary *dic =
                @{
                @"jsonKey":[self lowercaseFirstChar:key],
                @"jsonType":@"bool",
                @"classKey":[NSString stringWithFormat:@"%@%@",preName.stringValue,key],
                @"classType":@"BOOL",
                @"className":className
                };
                [array addObject:[dic mutableCopy]];
            }
                break;
            default:
                break;
        }
    }
}

-(NSString *)uppercaseFirstChar:(NSString *)str
{
    return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] uppercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}
-(NSString *)lowercaseFirstChar:(NSString *)str
{
        return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] lowercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}

-(void)showPropertys:(NSDictionary *)json
{
    array = nil;
    array = [[NSArrayController alloc] init];
    
    [self generateProperty:json withName:jsonName.stringValue];
    
    
   propertyWindowController = [[JSONPropertyWindowController alloc] initWithWindowNibName:@"JSONPropertyWindowController"];
    propertyWindowController.arrayController = array;
    [propertyWindowController.window makeKeyAndOrderFront:nil];
    
}



- (IBAction)generateClass:(id)sender {
    
    
    
    NSDictionary *json   = [jsonContent.string objectFromJSONString];
    
    if(json == nil)
    {
        jsonContent.string = @"json is invalid.";
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if(result == 0) return ;
        
        path = [panel.URL path];
        //[self generateClass:jsonName.stringValue forDic:json];
        [self getDataFromIt:json withName:jsonName.stringValue];
        jsonContent.string = @"generate .h.m(ARC)files，put those to the folder";
    
    }];

    
}

- (IBAction)checkProperty:(id)sender {
    
    NSDictionary *json   = [jsonContent.string objectFromJSONString];
    
    if(json == nil)
    {
        jsonContent.string = @"json is invalid.";
        return;
    }
    
    [self showPropertys:json];
}


-(BOOL)isStringDataArray:(NSArray *)theArray
{

    BOOL result=YES;
    
    for (id obj in theArray) {
        
        if ([self type:obj]==kArray) {
            result=NO;
            break;
        }
    }
    return result;
    
}

//表示该数组内有且只有字典 并且 结构一致。
-(BOOL)isDataArray:(NSArray *)theArray
{
    if(theArray.count <=0 ) return NO;
    for(id item in theArray)
    {
        if([self type:item] != kDictionary)
        {
            return NO;
        }
    }
    
    NSMutableSet *keys = [NSMutableSet set];
    for(NSString *key in [[theArray objectAtIndex:0] allKeys])
    {
        [keys addObject:key];
    }
    
    
    for(id item in theArray)
    {
        NSMutableSet *newKeys = [NSMutableSet set];
        for(NSString *key in [item allKeys])
        {
            [newKeys addObject:key];
        }
        
        if([keys isEqualToSet:newKeys] == NO)
        {
            return NO;
        }
    }
    return YES;
}


-(JsonValueType)type:(id)obj
{
    if([[obj className] isEqualToString:@"__NSCFString"] || [[obj className] isEqualToString:@"__NSCFConstantString"]) return kString;
    else if([[obj className] isEqualToString:@"__NSCFNumber"]) return kNumber;
    else if([[obj className] isEqualToString:@"__NSCFBoolean"])return kBool;
    else if([[obj className] isEqualToString:@"JKDictionary"])return kDictionary;
    else if([[obj className] isEqualToString:@"JKArray"])return kArray;
    return -1;
}

-(NSString *)typeName:(JsonValueType)type
{
    switch (type) {
        case kString:
            return @"NSString";
            break;
        case kNumber:
            return @"NSNumber";
            break;
        case kBool:
            return @"BOOL";
            break;
        case kArray:
        case kDictionary:
            return @"";
            break;
            
        default:
            break;
    }
}

@end















