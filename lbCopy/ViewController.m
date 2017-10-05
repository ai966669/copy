//
//  ViewController.m
//  lbCopy
//  
//  Created by ai966669 on 16/8/30.
//  Copyright © 2016年 ai966669. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController

- (void)setACopyMStr:(NSMutableString *)aCopyMStr {
    _aCopyMStr = [aCopyMStr copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    //给一个NSObject的变量A赋值B,我们其实是创建了一个指针A，然后指向了一个保存数据B的内存，这个内存地址是C。
//    NSMutableString *tempMStr = [[NSMutableString alloc] initWithString:@"strValue"];
//    NSLog(@"tempMStr指针地址:%p，tempMStr值%@ tempMStr值引用计数%@\n", tempMStr,tempMStr,[tempMStr valueForKey:@"retainCount"]); //tempMStr指针地址:0x7a05f650，tempStr值strValue tempStr值引用计数1
    
    //strong，weak，retain，copy和assgin区别。strong，weak在arc时出现，后三者在mrc时出现。
    //不同修饰符在不同类型变量中有不同的效果，变量分为可变非容器变量
    //可变非容器变量，如NSMutableString
    //不可变非容器变量,如NSString
    //可变容器变量，如NSMutableArray
    //不可变非容器变量，如NSArray
    //实验
    //1.可变非容器变量
    //1.copy会重新开辟内存地址，内存保存的数据是B。被赋值对象和原值修改互不影响。
    //2.strong会让指针指向C，同时给C的引用计数+1。所以原来值改变或者被赋值的值改变的时候，都会彼此影响。retain同strong
    //3.weak同strong,但他们不会给C的引用计数+1，应用计数为0的时候,内存将被释放，原来数据内存地址赋值为nil。
    //4.assign同weak，指向C并且计数不+1，区别在于assign不会对C值进行B数据的抹除操作，只是进行值释放。这就导致野指针存在，即当这块地址还没写上其他值前，能输出正常值，但一旦重新写上数据，该指针随时可能没有值，造成奔溃。

    NSLog(@"\n\n\n\n------------------可变变量实验------------------------");
    NSMutableString *mstrOrigin = [[NSMutableString alloc] initWithString:@"mstrOrigin in heap"];
    self.aCopyMStr = mstrOrigin;
    self.strongMStr = mstrOrigin;
    self.weakMStr = mstrOrigin;
    NSLog(@"mstrOrigin输出:指针地址%p,值地址%p,%@\n", &mstrOrigin,mstrOrigin,mstrOrigin);
    NSLog(@"aCopyMStr输出:指针地址%p,值地址%p,%@\n", &_aCopyMStr,_aCopyMStr,_aCopyMStr);
    NSLog(@"strongMStr输出:指针地址%p,值地址%p,%@\n", &_strongMStr,_strongMStr,_strongMStr);
    NSLog(@"weakMStr输出:指针地址%p,值地址%p,%@\n", &_weakMStr,_weakMStr,_weakMStr);
    NSLog(@"引用计数%@",[mstrOrigin valueForKey:@"retainCount"]);
    NSLog(@"引用计数%@",[_weakMStr valueForKey:@"retainCount"]); //？遗留问题，为什么此处_weakMStr是3
    NSLog(@"------------------结论------------------------");
    NSLog(@"除了copy修饰的aCopyMStr，strongMStr和weakMStr指针指向的内存地址都和mstrOrigin相同,但mstrOrigin内存引用计数为2，不为3，因为weakMStr不会增加指针指向的内存地址的计数指针。aCopyMStr赋值后则是自己单独在堆中开辟了一块内存，内存上保存“mstrOrigin”字符串，然后aCopyMStr指向了mstrOrigin");
    NSLog(@"------------------修改原值后------------------------");
    [mstrOrigin appendString:@"1"];
    NSLog(@"mstrOrigin输出:%p,%@\n", mstrOrigin,mstrOrigin);
    NSLog(@"aCopyMStr输出:%p,%@\n", _aCopyMStr,_aCopyMStr);
    NSLog(@"strongMStr输出:%p,%@\n", _strongMStr,_strongMStr);
    NSLog(@"weakMStr输出:%p,%@\n", _weakMStr,_weakMStr);
    NSLog(@"------------------结论------------------------");
    NSLog(@"aCopyMStr值没有改变被修改，其他都随之修改，验证结论1");
    NSLog(@"------------------修改原指针和strongMStr的指向------------------------");
    mstrOrigin = [[NSMutableString alloc] initWithString:@"mstrOriginChange2"];
    self.strongMStr = nil;
    NSLog(@"mstrOrigin输出:%p,%@\n", mstrOrigin,mstrOrigin);
    NSLog(@"strongMStr输出:%p,%@\n", _strongMStr,_strongMStr);
    NSLog(@"weakMStr输出:%p,%@\n", _weakMStr,_weakMStr);
    NSLog(@"------------------结论------------------------");
    NSLog(@"此时weakMStr没有值了，说明C随着strongMStr不再指向他，C被赋值nil，C的引用计数为0，证明结论2，3。");
    self.assignMStr = mstrOrigin;
    self.weakMStr = mstrOrigin;
    NSLog(@"mstrOrigin输出:%p,%@\n", mstrOrigin,mstrOrigin);
    NSLog(@"weakMStr输出:%p,%@\n", _weakMStr,_weakMStr);
    NSLog(@"assignMStr输出:%p,%@\n", _assignMStr,_assignMStr);
    mstrOrigin = [[NSMutableString alloc] initWithString:@"mstrOriginChange3"];
    NSLog(@"weakMStr输出:%p,%@\n", _weakMStr,_weakMStr);
//    NSLog(@"assignMStr输出:%p,%@\n", _assignMStr,_assignMStr);
    NSLog(@"------------------结论------------------------");
    NSLog(@"可以当mstrOrigin重新初始化后，assignMStr输出偶先奔溃，不奔溃的时候也存在值，且值不为nil。证明结论4");
    
 
    
    //2.不可变非容器变量NSString
    //不可变量因为变量本身不会变，所以其实任何赋值都没必要重新创建一个块内存，在这个不可变的内存中存放一样的值，节省内存的方式是都指向同一个地方。所以不可变量的拷贝都是浅拷贝，但依旧遵循一个原则就是copy和strong存在时，C依旧不会被释放。但只有weak时值依旧会被释放
    //1.copy会不会开辟内存地址，指针指向C，引用计数加1
    //2.strong指针指向C，引用计数不加1。
    //3.weak指针指向C，引用计数不加1。
    //4.assign同weak
    

    
    //dohere  nsstring的copy和strong以及assgin的区别不能通过引用计数来讲，因为nsstring是存在放在_TEXT段的，而引用计数是放在堆内存中的一个整型，对象alloc开辟堆内存空间后，引用计数自动置1；
    //_TEXT段：整个程序的代码，以及所有的常量。这部分内存是是固定大小的，只读的。了解_TEXT段内存管理方式，来分析copy ，strong，assgin的区别。
    NSLog(@"\n\n\n\n------------------不可变量实验------------------------");
    NSString *strOrigin = [[NSString alloc] initWithUTF8String:"strOrigin0123456"];
    self.aCopyStr  = strOrigin;  
    self.strongStr  = strOrigin;
    self.weakStr = strOrigin;
    NSLog(@"strOrigin输出:值地址%p,指针地址%p,%@\n", strOrigin,&strOrigin,strOrigin);
    NSLog(@"aCopyStr输出:值地址%p,指针地址%p,%@\n",  _aCopyStr,&_aCopyStr,_aCopyStr);
    NSLog(@"strongStr输出:值地址%p,指针地址%p,%@\n", _strongStr,&_strongStr,_strongStr);
    NSLog(@"weakStr输出:值地址%p,指针地址%p,%@\n", _weakStr,&_weakStr,_weakStr);
    NSLog(@"strOrigin值内存引用计数%@\n", [_strongStr valueForKey:@"retainCount"]);
    NSLog(@"------------------修改原值后------------------------");
    strOrigin = [[NSString alloc] initWithUTF8String:"aaa"];
    NSLog(@"strOrigin输出:%p,%@\n", strOrigin,strOrigin);
    NSLog(@"aCopyStr输出:%p,%@\n", _aCopyStr,_aCopyStr);
    NSLog(@"strongStr输出:%p,%@\n", _strongStr,_strongStr);
    NSLog(@"weakStr输出:%p,%@\n", _weakStr,_weakStr);
    NSLog(@"------------------结论------------------------");
    NSLog(@"strOrigin值被改变，其他指针指向没有变化。说明不可变类型值不可被修改，只能被重新初始化");
    self.aCopyStr  = nil;
    self.strongStr  = nil;
    NSLog(@"strOrigin输出:%p,%@\n", strOrigin,strOrigin);
    NSLog(@"aCopyStr输出:%p,%@\n", _aCopyStr,_aCopyStr);
    NSLog(@"strongStr输出:%p,%@\n", _strongStr,_strongStr);
    NSLog(@"weakStr输出:%p,%@\n", _weakStr,_weakStr);
    NSLog(@"------------------结论------------------------");
    NSLog(@"当只有weakStr拥有C时，值依旧会被释放，同非容器可变变量");
    
    
    //3.可变容器变量，如NSMutableArray。容器本身和可变非容器变量一样。但容器中的数据不管是copy和weak，还是strong都是浅拷贝
    NSMutableArray   *mArrOrigin = [[NSMutableArray alloc] init];
    NSMutableString  *mstr1 = [[NSMutableString alloc] initWithString:@"value1"];
    NSMutableString  *mstr2 = [[NSMutableString alloc] initWithString:@"value2"];
    NSMutableString  *mstr3 = [[NSMutableString alloc] initWithString:@"value3"];
    [mArrOrigin addObject:mstr1];
    [mArrOrigin addObject:mstr2];
    self.aCopyMArr = mArrOrigin;
    self.strongMArr = mArrOrigin;
    self.weakMArr = mArrOrigin;
    NSLog(@"mArrOrigin输出:%p,%@\n", mArrOrigin,mArrOrigin);
    NSLog(@"aCopyMArr输出:%p,%@\n", _aCopyMArr,_aCopyMArr);
    NSLog(@"strongMArr输出:%p,%@\n", _strongMArr,_strongMArr);
    NSLog(@"weakMArr输出:%p,%@\n", _weakMArr,_weakMArr);
    NSLog(@"weakMArr输出:%p,%@\n", _weakMArr[0],_weakMArr[0]);
    NSLog(@"mArrOrigin中的数据引用计数%@", [mArrOrigin valueForKey:@"retainCount"]);
    NSLog(@"%p %p %p %p",&mArrOrigin,mArrOrigin,mArrOrigin[0],mArrOrigin[1]);
    [_weakMArr addObject:mstr3];
    NSLog(@"mArrOrigin输出:%p,%@\n" , mArrOrigin,mArrOrigin);
    NSLog(@"aCopyMArr输出:%p,%@\n", _aCopyMArr,_aCopyMArr);
    NSLog(@"strongMArr输出:%p,%@\n", _strongMArr,_strongMArr);
    NSLog(@"weakMArr输出:%p,%@\n", _weakMArr,_weakMArr);
    NSLog(@"mArrOrigin中的数据引用计数%@", [mArrOrigin valueForKey:@"retainCount"]);
    NSLog(@"-------aCopyMArr输出:%p,%@ %@\n", mstr1,mstr1,[mstr1 valueForKey:@"retainCount"]);
    [mstr1 appendFormat:@"aaa"];
    NSLog(@"mArrOrigin输出:%p,%@\n" , mArrOrigin,mArrOrigin);
    NSLog(@"aCopyMArr输出:%p,%@\n", _aCopyMArr,_aCopyMArr);
    NSLog(@"strongMArr输出:%p,%@\n", _strongMArr,_strongMArr);
    NSLog(@"weakMArr输出:%p,%@\n", _weakMArr,_weakMArr);
    NSLog(@"------------------结论------------------------");
    NSLog(@"发现除了CopyMArr其他数组地址都一样，也就是说除了copy其他都是指针指向C而已，也就是浅拷贝。修改容器本身，只对浅拷贝的值影响，不对copy的值影响");
    NSLog(@"mArrOrigin中的第一个数据输出:%p,%@\n", mArrOrigin[0],mArrOrigin[0]);
    NSLog(@"aCopyMArr中的第一个数据输出:%p,%@\n", _aCopyMArr[0],_aCopyMArr[0]);
    NSLog(@"strongMArr中的第一个数据输出:%p,%@\n", _strongMArr[0],_strongMArr[0]);
    NSLog(@"weakMArr中的第一个数据输出:%p,%@\n", _weakMArr[0],_weakMArr[0]);
    [mstr1 appendFormat:@"change"];
    NSLog(@"mArrOrigin中的第一个数据输出:%p,%@\n", mArrOrigin[0],mArrOrigin[0]);
    NSLog(@"aCopyMArr中的第一个数据输出:%p,%@\n", _aCopyMArr[0],_aCopyMArr[0]);
    NSLog(@"strongMArr中的第一个数据输出:%p,%@\n", _strongMArr[0],_strongMArr[0]);
    NSLog(@"weakMArr中的第一个数据输出:%p,%@\n", _weakMArr[0],_weakMArr[0]);
    NSLog(@"------------------结论------------------------");
    NSLog(@"容器本身会因为不同修饰符进行有深浅拷贝，但容器中的值地址都是同一个，修改后被赋值的数组都会修改。");
    mArrOrigin = nil;
    self.aCopyMArr = nil;
    self.strongMArr = nil;
    NSLog(@"mArrOrigin中的第一个数据输出:%p,%@\n", mArrOrigin[0],mArrOrigin[0]);
    NSLog(@"aCopyMArr中的第一个数据输出:%p,%@\n", _aCopyMArr[0],_aCopyMArr[0]);
    NSLog(@"strongMArr中的第一个数据输出:%p,%@\n", _strongMArr[0],_strongMArr[0]);
    NSLog(@"weakMArr中的第一个数据输出:%p,%@\n", _weakMArr[0],_weakMArr[0]);
    NSLog(@"------------------结论------------------------");
    NSLog(@"当aCopyMArr和strongMArr为nil时，也就是说C只有被weakMArr连接的时候，规则和可变非容器变量，不可变非容器变量一样，weakMarr也会被释放");
    
    //4.不可变非容器变量，如NSArray。容器本身和不可变非容器变量一样，但容器内的值永远是浅拷贝，自行试验
//    总结
//    copy，strong，weak，assign的区别。
//    可变变量中，copy是重新开辟一个内存，strong，weak，assgin后三者不开辟内存，只是指针指向原来保存值的内存的位置，storng指向后会对该内存引用计数+1，而weak，assgin不会。weak，assgin会在引用保存值的内存引用计数为0的时候值为空，并且weak会将内存值设为nil，assign不会，assign在内存没有被重写前依旧可以输出，但一旦被重写将出现奔溃
//    不可变变量中，因为值本身不可被改变，copy没必要开辟出一块内存存放和原来内存一模一样的值，所以内存管理系统默认都是浅拷贝。其他地方和可变变量一样，如weak修饰的变量同样会在内存引用计数为0时变为nil。
//    容器本身遵守上面准则，但容器内部的每个值都是浅拷贝。
//    综上所述，当创建property构造器创建变量value1的时候，使用copy，strong，weak，assign根据具体使用情况来决定。value1 = value2，如果你希望value1和value2的修改不会互相影响的就用用copy，反之用strong，weak,assign。如果你还希望原来值C为nil的时候，你的变量不为nil就用strong,反之用weak和assign。

    
//    实际应用，不同页面之间值如果希望同时被修改就用strong，如果同时修改但希望不强引用就是用weak，如果只是拿这个值就用copy。数组拷贝的时候要注意，里面元素不会深拷贝，如果希望强拷贝
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
