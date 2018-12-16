//
//  main.swift
//  操作系统_exp2.2_ 页式虚拟存储地址变换_Swift
//
//  Created by wejudging on 2018/12/9.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation






struct Page
{
    /*页号*/
    var lnumber:Int = 0
    /*表示该页是否在主存，"1"表示在主存中，"0"表示不在*/
    var flag:Int = 0
    /*该页所在主存块的块号*/
    var pnumber:Int = 0
    /*该页是否被修改过，"1"表示修改过，"0"表示没有修改过*/
    var write:Int = 0
    /*该页存放在磁盘上的位置，即磁盘块号*/
    var dnumber:Int = 0
   
}
var pp : Page = Page.init()




var page = [Page](repeating: pp, count: 64)
/*m为该作业在主存中的主存块块数*/
var m:Int = 0
/*页表实际长度*/
var page_length:Int = 0
/*主存中页号队列，指向下次要被替换的页号*/
var head:Int = 0
/*存放在主存中的页的页号*/
var p = [Int](repeating: 0, count: 10)
var fast = LURCache(cacheSize: 4)



/*命令处理函数*/
func command(laddress:Int,write:Int)
{   //分别存放物理地址、页内地址和外存地址（盘块号）
    var paddress:Int?,ad:Int?,pnumber:Int?
    //存放页号
    var lnumber:Int?
    //页号=逻辑地址/2^10
    /*先计算出页号（高6位）和页内地址（低10位）；*/
    lnumber=laddress>>10
    //页内地址利用位运算来取出后10位
    ad=laddress%0x3ff
    // var o:Any = 0
    if(fast.get(key: String(lnumber!))! == 0)
    {
    
    var b:Int = 0
    while b==0 {
        
    
        if(lnumber! >= page_length)    /*判断页号是否越界，若越界，显示越界不再进行地址变换；*/
    {
        print("不存在该页")
        return;
    }
    if(page[lnumber!].flag==1)   /*若访问的页在内存，查找对应的物理块，计算物理地址；若不在内存，先调用page_interrupt(int lnumber)进行页面置换，再进行地址变换。*/
        
    {
        pnumber=page[lnumber!].pnumber
        paddress=pnumber!<<10|ad!
        print("逻辑地址是:\(laddress),对应物理地址是:\(paddress ?? 0000)")
        fast.put(key: String(lnumber!), anyO: pnumber!)
        if(write==1)
        {page[lnumber!].write=1}
        b = 1
    }
    else
    {
        if(lnumber!>=page_length)    /*判断页号是否越界，若越界，显示越界不再进行地址变换；*/
        {
            print("不存在该页");
            return;
        }
        else{
            page_interrupt(lnumber: lnumber!)
            
        }
        }
    
    }
    }
    else{
        pnumber=fast.get(key: String(lnumber!))!
        //pnumber=page[lnumber!].pnumber
        paddress=pnumber!<<10|ad!
        print("快表查询")
        print("逻辑地址是:\(laddress),对应物理地址是:\(paddress ?? 0000)")
        
        if(write==1)
        {page[lnumber!].write=1}
        
        
    }
}


/*缺页中断处理函数，采用FIFO页面置换算法*/
func page_interrupt(lnumber:Int) {
    var j:Int = 0
    print("发生缺页中断* \(lnumber)",lnumber);
    /*淘汰页*/
    j=p[head]
    /* 装入替换后的新页号*/
    p[head]=lnumber
    head=(head+1)%m
    if (page[j].write==1){
        print("将页\(j)写回磁盘第\(page[j].dnumber)块")}
    /*修改页表*/
    page[j].flag=0/* 第j页被换出，第j页存在标志改为"0"*/
    page[lnumber].pnumber=page[j].pnumber/* 第lnumber页装入原来第j页所在的物理块*/
    page[lnumber].flag=1/* 第lnumber页存在标志改为"1"*/
    page[lnumber].write=0/* 第lunmber页修改标志改为"0"*/
    print("淘汰主存块\(page[j].pnumber)中的页\(j)，从磁盘第\(page[lnumber].dnumber)块中调入页\(lnumber)")
}








var lnumber=0,pnumber=0,write=0,dnumber=0,laddress:Int?,i=0
/*输入页表的信息，页号从0开始，依次编号，创建页表page*/
print("输入页表的信息，创建页表（若页号为－1，则结束输入）")
repeat{
    print("输入页号:")
    lnumber =  Int(readLine()!) ?? 0
    print("输入块号:")
    dnumber =  Int(readLine()!) ?? 0
    page[i].lnumber=lnumber
    page[i].flag=0
    page[i].write=0
    page[i].dnumber=dnumber
    i += 1
}
while(lnumber != -1)

page_length=i-1//因为多输入了一个-1
print("输入主存块号，主存块数要小于\(i-1)(以－1结束）")
pnumber =  Int(readLine()!) ?? 0
while(pnumber != -1)
{
    if(m<=i)
    {
        page[m].pnumber=pnumber
        page[m].flag=1
        p[m]=m//对数组P进行初始化，一开始程序的前m+1页调入内存
        m+=1
    }
    pnumber =  Int(readLine()!) ?? 0
}
print("输入指令性质(1-修改,0-不需要，其他-结束程序运行)和逻辑地址:")
write =  Int(readLine()!) ?? 0
laddress =  Int(readLine()!) ?? 0
while(write==0||write==1)
{
    command(laddress: laddress!,write: write)/* 执行指令*/
    print("输入指令性质(1-修改,0-不需要，其他-结束程序运行)和逻辑地址:")
    write =  Int(readLine()!) ?? 0
    laddress =  Int(readLine()!) ?? 0
}
