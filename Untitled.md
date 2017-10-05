#iOS中copy,strong,retain,weak和assign的区别

在知道他们区别之前，我们首先要知道NSObject对象的赋值操作做了哪些操作。

A=C其实是在内存中创建了一个A，然后又开辟了一个内存B，B里面存放的着值C。


NSObject赋值示意图1
如下：
```
NSMutableString*tempMStr = [[NSMutableString alloc]initWithString:@"strValue"];NSMutableString*tempMStr = [[NSMutableString alloc]initWithString:@"strValue"];

NSLog(@"tempMStr值地址:%p，tempMStr值%@ tempMStr值引用计数%@\n", tempMStr,tempMStr[tempMStrvalueForKey:@"retainCount"]);[tempMStrvalueForKey:@"retainCount"]);[tempMStrvalueForKey:@"retainCount"]);[tempMStrvalueForKey:@"retainCount"]);
```


//输出：tempMStr值地址:0x7a05f650，tempMStr值strValue tempMStr值引用计数1
此处tempMStr就是A，值地址就是C，“strValue”就是b，而引用计数这个概念是针对堆中的数据，赋值给其他值或者指针设置为nil，如tempStr = nil，都会使得引用计数有所增减，如果该内存区域引用计数为0时就将数据抹除。而我们使用copy，strong,retain,weak,assign影响的就是是否开辟新的内存和是否对C是否进行引用计数增加。

1.以典型的NSMutableString为例


@property(copy,nonatomic)NSMutableString*aCopyMStr;

@property(strong,nonatomic)NSMutableString*strongMStr;

@property(weak,nonatomic)NSMutableString*weakMStr;

@property(assign,nonatomic)NSMutableString*assignMStr;
NSMutableString*mstrOrigin = [[NSMutableStringalloc]initWithString:@"mstrOriginValue"];

self.aCopyMStr= mstrOrigin;

self.strongMStr= mstrOrigin;

self.strongMStr= mstrOrigin;

self.weakMStr= mstrOrigin;

NSLog(@"mstrOrigin输出:%p,%@\n", mstrOrigin,mstrOrigin);

NSLog(@"aCopyMStr输出:%p,%@\n",_aCopyMStr,_aCopyMStr);

NSLog(@"strongMStr输出:%p,%@\n",_strongMStr,_strongMStr);

NSLog(@"weakMStr输出:%p,%@\n",_weakMStr,_weakMStr);

NSLog(@"引用计数%@",[mstrOriginvalueForKey:@"retainCount"]);
2016-09-01 15:19:13.134 lbCopy[1205:87583] mstrOrigin输出:0x7892a5e0,mstrOriginValue
2016-09-01 15:19:13.135 lbCopy[1205:87583] aCopyMStr输出:0x7893deb0,mstrOriginValue
2016-09-01 15:19:13.135 lbCopy[1205:87583] strongMStr输出:0x7892a5e0,mstrOriginValue
2016-09-01 15:19:13.135 lbCopy[1205:87583] weakMStr输出:0x7892a5e0,mstrOriginValue

2016-09-01 15:19:13.135 lbCopy[1205:87583] 引用计数2
除了copy修饰的aCopyMStr，strongMStr和weakMStr指针指向的内存地址都和mstrOrigin相同,但mstrOrigin内存引用计数为2，不为3，因为weakMStr不会增加指针指向的内存地址的计数指针。aCopyMStr赋值后则是自己单独在堆中开辟了一块内存，内存上保存“mstrOrigin”字符串，然后aCopyMStr指向了mstrOrigin。

拷贝示意图如下


NSMutableString拷贝示意图2
可见当我修改mstrOrigin的值的时候，必然不会影响aCopyMStr,只会影响strongMStr和weakMStr。验证下

NSLog(@"------------------修改原值后------------------------");

[mstrOriginappendString:@"1"];

NSLog(@"mstrOrigin输出:%p,%@\n", mstrOrigin,mstrOrigin);

NSLog(@"aCopyMStr输出:%p,%@\n",_aCopyMStr,_aCopyMStr);

NSLog(@"strongMStr输出:%p,%@\n",_strongMStr,_strongMStr);

NSLog(@"weakMStr输出:%p,%@\n",_weakMStr,_weakMStr);
输出结果

2016-09-01 15:33:02.839 lbCopy[1205:87583] mstrOrigin输出:0x7892a5e0,mstrOrigin1

2016-09-01 15:33:02.839 lbCopy[1205:87583] aCopyMStr输出:0x7893deb0,mstrOrigin

2016-09-01 15:33:02.839 lbCopy[1205:87583] strongMStr输出:0x7892a5e0,mstrOrigin1

2016-09-01 15:33:02.839 lbCopy[1205:87583] weakMStr输出:0x7892a5e0,mstrOrigin1
所以：copy会重新开辟内存地址，内存保存的数据是B。被赋值对象和原值修改互不影响。

1.1那么weak和strong的区别呢？
上面提到weakMStr不会增加值地址C的引用计数，并且说道到引用计数为0的时候，值会变为nil，那么我们初始化mstrOrigin和并将strongMStr设置为nil让C的引用计数为0，然后输出weakMStr，看是否为nil.（初始化和设为nil都可以将指针所指向的值地址引用计数减少1）

mstrOrigin = [[NSMutableStringalloc]initWithString:@"mstrOriginChange2"];

self.strongMStr=nil;

NSLog(@"mstrOrigin输出:%p,%@\n", mstrOrigin,mstrOrigin);

NSLog(@"strongMStr输出:%p,%@\n",_strongMStr,_strongMStr);

NSLog(@"weakMStr输出:%p,%@\n",_weakMStr,_weakMStr);
输出结果

2016-09-01 15:41:33.793 lbCopy[1247:100742] mstrOrigin输出:0x7874d140,mstrOriginChange2

2016-09-01 15:41:33.793 lbCopy[1247:100742] strongMStr输出:0x0,(null)

2016-09-01 15:41:33.794 lbCopy[1247:100742] weakMStr输出:0x0,(null)
可见之前引用计数2是mstrOrigin和strongMStr添加的。所以strong和weak虽然都指向原来值的地址，但前者会对值地址进行引用计数+1防止原地址值被释放，但后者不会，当其他值都不在指向值地址时，weak的值也就是为nil了。

1.2那assign和weak又有什么区别呢
我们实验以下代码

self.assignMStr= mstrOrigin;

self.weakMStr= mstrOrigin;

mstrOrigin = [[NSMutableStringalloc]initWithString:@"mstrOriginChange3"];

NSLog(@"weakMStr输出:%p,%@\n",_weakMStr,_weakMStr);

NSLog(@"assignMStr输出:%p,%@\n",self.assignMStr,self.assignMStr);
可以发现在输出assignMStr时会偶尔出现奔溃的情况。原因是发送了野指针的情况。assign同weak，指向C并且计数不+1，但当C地址引用计数为0时，assign不会对C地址进行B数据的抹除操作，只是进行值释放。这就导致野指针存在，即当这块地址还没写上其他值前，能输出正常值，但一旦重新写上数据，该指针随时可能没有值，造成奔溃。

1.3那retain是什么
ARC之前属性构造器的关键字是retain,copy,assign，strong和weak是ARC带出来的关键字。retain现在同strong，就是指针指向值地址，同时进行引用计数加1。

2.非NSMutableString的情况
上面我们讨论了典型的例子NSMutableString，即非容器可变变量。也就是说还存在其他三种类型需要讨论...

1.非容器不可变变量NSSting

2.容器可变变量NSMutableArray

3.容器不可变变量NSArray

更重要的是不同类型会有不同结果...，好吧，不要奔溃，上面一大段我们讨论了1/4。接下来我们要讨论其他的3/4情况。但好消息是，其他几种情况基本都是上面非容器可变变量情况类似的。

2.1容器可变变量
容器可变变量的典型例子就是NSMutableArray

@property(copy,nonatomic)NSMutableArray*aCopyMArr;

@property(strong,nonatomic)NSMutableArray*strongMArr;

@property(weak,nonatomic)NSMutableArray*weakMArr;
NSMutableArray*mArrOrigin = [[NSMutableArrayalloc]init];

NSMutableString*mstr1 = [[NSMutableStringalloc]initWithString:@"value1"];

NSMutableString*mstr2 = [[NSMutableStringalloc]initWithString:@"value2"];

NSMutableString*mstr3 = [[NSMutableStringalloc]initWithString:@"value3"];

[mArrOriginaddObject:mstr1];

[mArrOriginaddObject:mstr2];

self.aCopyMArr= mArrOrigin;

self.strongMArr= mArrOrigin;

self.weakMArr= mArrOrigin;

NSLog(@"mArrOrigin输出:%p,%@\n", mArrOrigin,mArrOrigin);

NSLog(@"aCopyMArr输出:%p,%@\n",_aCopyMArr,_aCopyMArr);

NSLog(@"strongMArr输出:%p,%@\n",_strongMArr,_strongMArr);

NSLog(@"weakMArr输出:%p,%@\n",_weakMArr,_weakMArr);
NSLog(@"weakMArr输出:%p,%@\n",_weakMArr[0],_weakMArr[0]);

NSLog(@"mArrOrigin中的数据引用计数%@", [mArrOriginvalueForKey:@"retainCount"]);

NSLog(@"%p %p %p %p",&mArrOrigin,mArrOrigin,mArrOrigin[0],mArrOrigin[1]);

[mArrOriginaddObject:mstr3];

NSLog(@"mArrOrigin输出:%p,%@\n", mArrOrigin,mArrOrigin);

NSLog(@"aCopyMArr输出:%p,%@\n",_aCopyMArr,_aCopyMArr);

NSLog(@"strongMArr输出:%p,%@\n",_strongMArr,_strongMArr);

NSLog(@"weakMArr输出:%p,%@\n",_weakMArr,_weakMArr);
NSLog(@"mArrOrigin中的数据引用计数%@", [mArrOriginvalueForKey:@"retainCount"]);

[mstr1appendFormat:@"aaa"];

NSLog(@"mArrOrigin输出:%p,%@\n", mArrOrigin,mArrOrigin);

NSLog(@"aCopyMArr输出:%p,%@\n",_aCopyMArr,_aCopyMArr);

NSLog(@"strongMArr输出:%p,%@\n",_strongMArr,_strongMArr);

NSLog(@"weakMArr输出:%p,%@\n",_weakMArr,_weakMArr);
2016-09-02 20:42:30.777 lbCopy[4207:475091] mArrOrigin输出:0x78f81680,(

value1,

value2

)
2016-09-02 20:42:30.777 lbCopy[4207:475091] aCopyMArr输出:0x7a041340,(

value1,

value2

)
2016-09-02 20:42:30.777 lbCopy[4207:475091] strongMArr输出:0x78f81680,(

value1,

value2

)
2016-09-02 20:42:30.777 lbCopy[4207:475091] weakMArr输出:0x78f81680,(

value1,

value2

)
2016-09-02 20:42:30.777 lbCopy[4207:475091] weakMArr输出:0x78f816a0,value1

2016-09-02 20:42:30.778 lbCopy[4207:475091] mArrOrigin中的数据引用计数(

3,

3

)
2016-09-02 20:42:30.778 lbCopy[4207:475091] 0xbffb4098 0x78f81680 0x78f816a0 0x78f81710

2016-09-02 20:42:30.778 lbCopy[4207:475091] mArrOrigin输出:0x78f81680,(

value1,

value2,

value3

)
2016-09-02 20:42:30.778 lbCopy[4207:475091] aCopyMArr输出:0x7a041340,(

value1,

value2

)
2016-09-02 20:42:30.778 lbCopy[4207:475091] strongMArr输出:0x78f81680,(

value1,

value2,

value3

)
2016-09-02 20:42:30.778 lbCopy[4207:475091] weakMArr输出:0x78f81680,(

value1,

value2,

value3

)
2016-09-02 20:42:30.779 lbCopy[4207:475091] mArrOrigin中的数据引用计数(

3,

3,

2

)
2016-09-02 20:42:30.779 lbCopy[4207:475091] mArrOrigin输出:0x78f81680,(

value1aaa,

value2,

value3

)
2016-09-02 20:42:30.779 lbCopy[4207:475091] aCopyMArr输出:0x7a041340,(

value1aaa,

value2

)
2016-09-02 20:42:30.779 lbCopy[4207:475091] strongMArr输出:0x78f81680,(

value1aaa,

value2,

value3

)
2016-09-02 20:42:30.779 lbCopy[4207:475091] weakMArr输出:0x78f81680,(

value1aaa,

value2,

value3

)
上面代码有点多，所做的操作是mArrOrigin（value1,value2）赋值给aCopyMArr,strongMArr,weakMArr。然后输出mArrOrigin的引用计数，和数组地址。发现其中数组本身指向的内存地址除了aCopyMArr重新开辟了一块地址，strongMArr,weakMArr和mArrOrigin指针指向的地址是一样的。也就是说

容器可变变量中容器本身和非容器可变变量是一样的，copy深拷贝，strongMArr,weakMArr和assign都是浅拷贝

另外我们发现背拷贝对象mArrOrigin中的数据引用计数居然不是1而是3。也就是说容器内的数据拷贝都是进行了深拷贝。同事当我们修改数组中的一个数据时strongMArr,weakMArr，aCopyMArr中的数据都改变了，说明

容器可变变量中的数据在拷贝的时候都是浅拷贝

容器可变变量的拷贝结构如下图




NSMutableArray拷贝示意图3
2.2非容器不变变量

典型例子是NSString

我们还是以代码引出结果

@property(copy,nonatomic)NSString*aCopyStr;

@property(strong,nonatomic)NSString*strongStr;

@property(weak,nonatomic)NSString*weakStr;

@property(assign,nonatomic)NSString*assignStr;
NSLog(@"\n\n\n\n------------------不可变量实验------------------------");

NSString*strOrigin = [[NSStringalloc]initWithUTF8String:"string 1"];

self.aCopyStr= strOrigin;

self.strongStr= strOrigin;

self.weakStr= strOrigin;

NSLog(@"strOrigin输出:%p,%@\n", strOrigin,strOrigin);

NSLog(@"aCopyStr输出:%p,%@\n",_aCopyStr,_aCopyStr);

NSLog(@"strongStr输出:%p,%@\n",_strongStr,_strongStr);

NSLog(@"weakStr输出:%p,%@\n",_weakStr,_weakStr);

NSLog(@"------------------修改原值后------------------------");

strOrigin =@"aaa";

NSLog(@"strOrigin输出:%p,%@\n", strOrigin,strOrigin);

NSLog(@"aCopyStr输出:%p,%@\n",_aCopyStr,_aCopyStr);

NSLog(@"strongStr输出:%p,%@\n",_strongStr,_strongStr);

NSLog(@"weakStr输出:%p,%@\n",_weakStr,_weakStr);

NSLog(@"------------------结论------------------------");

NSLog(@"strOrigin值值为改变，但strOrigin和aCopyStr指针地址和指向都已经改变，说明不可变类型值不可被修改，重新初始化");

self.aCopyStr=nil;

self.strongStr=nil;

NSLog(@"strOrigin输出:%p,%@\n", strOrigin,strOrigin);

NSLog(@"aCopyStr输出:%p,%@\n",_aCopyStr,_aCopyStr);

NSLog(@"strongStr输出:%p,%@\n",_strongStr,_strongStr);

NSLog(@"weakStr输出:%p,%@\n",_weakStr,_weakStr);

NSLog(@"------------------结论------------------------");

NSLog(@"当只有weakStr拥有C时，值依旧会被释放，同非容器可变变量");
------------------不可变量实验------------------------

2016-09-02 21:08:44.053 lbCopy[4297:488549] strOrigin输出:0x7a2550d0,string 1

2016-09-02 21:08:44.053 lbCopy[4297:488549] aCopyStr输出:0x7a2550d0,string 1

2016-09-02 21:08:44.054 lbCopy[4297:488549] strongStr输出:0x7a2550d0,string 1

2016-09-02 21:08:44.054 lbCopy[4297:488549] weakStr输出:0x7a2550d0,string 1

2016-09-02 21:08:44.054 lbCopy[4297:488549] strOrigin值内存引用计数3

2016-09-02 21:08:44.054 lbCopy[4297:488549] ------------------修改原值后------------------------

2016-09-02 21:08:44.054 lbCopy[4297:488549] strOrigin输出:0x8c1f8,aaa

2016-09-02 21:08:44.054 lbCopy[4297:488549] aCopyStr输出:0x7a2550d0,string 1

2016-09-02 21:08:44.054 lbCopy[4297:488549] strongStr输出:0x7a2550d0,string 1

2016-09-02 21:08:44.055 lbCopy[4297:488549] weakStr输出:0x7a2550d0,string 1

2016-09-02 21:08:44.055 lbCopy[4297:488549] ------------------结论------------------------

2016-09-02 21:08:44.055 lbCopy[4297:488549] strOrigin值值为改变，但strOrigin和aCopyStr指针地址和指向都已经改变，说明不可变类型值不可被修改，重新初始化

2016-09-02 21:08:44.059 lbCopy[4297:488549] strOrigin输出:0x8c1f8,aaa

2016-09-02 21:08:44.059 lbCopy[4297:488549] aCopyStr输出:0x0,(null)

2016-09-02 21:08:44.060 lbCopy[4297:488549] strongStr输出:0x0,(null)

2016-09-02 21:08:44.060 lbCopy[4297:488549] weakStr输出:0x0,(null)

2016-09-02 21:08:44.060 lbCopy[4297:488549] ------------------结论------------------------

2016-09-02 21:08:44.061 lbCopy[4297:488549]当只有weakStr拥有C时，值依旧会被释放，同非容器可变变量
此处我们将strOrigin拷贝给aCopyStr，strongStr，weakStr，然后输出他们的值地址，发现他们四个的值地址一样，且strOrigin值的引用计数为3。修改strOrigin和发现strOrigin值地址改变，其他三个值地址不变，将aCopyStr，strongStr设为nil后，发现weakStr随之nil。

综合上面现象发现除了copy是浅拷贝外，其他特性和非容器可变变量一样。那么为什么copy是浅拷贝呢，也就是说为什么aCopyStr不自己开辟一个独立的内存出来呢。答案很简单，因为不可变量的值不会改变，既然都不会改变，所以没必要重新开辟一个内存出来让aCopyStr指向他，直接指向原来值位置就可以了。示意图如下


NSString拷贝示意图4
非容器不可变量除了copy其他特性同非容器可变变量，copy是浅拷贝

2.3不可变容器变量
典型对象NSArray。该对象实验自行实验。但结论在这里给出，其实不实验也可以大概知道概率

在不可变容器变量中，容器本身都是浅拷贝包括copy，同NSString，容器里面的数据都是浅拷贝，同NSMutableArray。

3.总结
copy，strong，weak，assign的区别。

可变变量中，copy是重新开辟一个内存，strong，weak，assgin后三者不开辟内存，只是指针指向原来保存值的内存的位置，storng指向后会对该内存引用计数+1，而weak，assgin不会。weak，assgin会在引用保存值的内存引用计数为0的时候值为空，并且weak会将内存值设为nil，assign不会，assign在内存没有被重写前依旧可以输出，但一旦被重写将出现奔溃

不可变变量中，因为值本身不可被改变，copy没必要开辟出一块内存存放和原来内存一模一样的值，所以内存管理系统默认都是浅拷贝。其他地方和可变变量一样，如weak修饰的变量同样会在内存引用计数为0时变为nil。

容器本身遵守上面准则，但容器内部的每个值都是浅拷贝。

综上所述，当创建property构造器创建变量value1的时候，使用copy，strong，weak，assign根据具体使用情况来决定。value1 = value2，如果你希望value1和value2的修改不会互相影响的就用用copy，反之用strong,weak,assign。如果你还希望原来值C(C是什么见示意图1)为nil的时候，你的变量不为nil就用strong,反之用weak和assign。weak和assign保证了不强引用某一块内存，如delegate我们就用weak表示，就是为了防止循环引用的产生。

补充
delegate为什么要用weak或者assign而不用strong，a创建对象b,b中有C类对象c，所以a对b有一个引用,b对c有一个引用，a.b引用计数分别为1，1。当c.delegate = b的时候，实则是对a有了一个引用，如果此时c的delegate用strong修饰则会对b的值内存引用计数+1，b引用计数为2。当a的生命周期结束，随之释放对b的引用，b的引用计数变为1，导致b不能释放，b不能释放又导致b对c的引用不能释放，c引用计数还是为1，这样就造成了b和c一直留在了内存中。

而要解决这个问题就是使用weak或者assign修饰delegate，这样虽然会有c仍然会对b有一个引用，但是引用是弱引用，当a生命周期结束的时候，b的引用计数变为0，b释放后随之c的引用消失，c引用计数变为0，释放。

项目地址git@github.com:ai966669/copy.git

交流qq:578172874

错误之处希望能帮忙提出来，O(∩_∩)O谢谢了