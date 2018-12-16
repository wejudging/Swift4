//
//  main.swift
//  地址变换—swift
//
//  Created by wejudging on 2018/12/16.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation
var page_length = 0 , pnumber = 0//块号
var lnumber = 0 //页号
var address = 0//页内地址
var paddress = 0 //物理地址
var fast = LURCache(cacheSize: 4)//快表定义
struct Block {
    //指向页表始址
    var start:UnsafeMutablePointer<Int>?
    //指向页表始址
    var end:UnsafeMutablePointer<Int>?
  }
//定义内存盘块的堆栈
var PageBlock:Block = Block.init(start: UnsafeMutablePointer<Int>.allocate(capacity: 4*8),end: UnsafeMutablePointer<Int>.allocate(capacity: 4*8))

struct Page
{   /*页号*/
    var lnumber:Int = 0
    /*该页所在主存块的块号*/
    var pnumber:Int = 0
    /*该页是否被修改过，"1"表示修改过，"0"表示没有修改过*/
    var write:Int = 0
}

var pp : Page = Page.init()
var page = [Page](repeating: pp, count: 64)


func Show()  {
//    for i in 0..<page_length{
//        print("页号:\(page[i].lnumber)")
//        print("块号:\(page[i].pnumber)")
//    }
    
    PageBlock.end=PageBlock.start
    for _ in 0..<page_length{
         print("页号:\(page_length)")
        print((PageBlock.end?.pointee)!)
        PageBlock.end=PageBlock.end!+1
    }
}


func Switch(laddress:Int) -> Int {
    
    
    /*先计算出页号（高6位）和页内地址（低10位）*/
    //页号=逻辑地址/2^10
    lnumber=laddress>>10
    //页内地址利用位运算来取出后10位
    address=laddress%0x3ff
    if(fast.get(key: String(lnumber))! == 0)
    {
        /*判断页号是否越界，若越界，显示越界不再进行地址变换；*/
        if(lnumber >= page_length)
        {   print("越界中断")
            return 0
        }
        PageBlock.end=PageBlock.start
        PageBlock.end=PageBlock.end!+lnumber
        //  pnumber=page[lnumber].pnumber
        pnumber = (PageBlock.end?.pointee)!
        paddress=pnumber<<10|address
        // print("逻辑地址是:\(laddress),对应物理地址是:\(paddress )")
        fast.put(key: String(lnumber), anyO: pnumber)
        return paddress
    }
    else{
        pnumber=fast.get(key: String(lnumber))!
        //pnumber=page[lnumber!].pnumber
        paddress=pnumber<<10|address
        print("快表查询!")
       // print("逻辑地址是:\(laddress),对应物理地址是:\(paddress ?? 0000)")
        return paddress
    }
    
    
}




/*输入页表的信息，页号从0开始，依次编号，创建页表page*/
print("输入页表的信息，创建页表（若页号为－1，则结束输入)")
PageBlock.end = PageBlock.start
repeat{
    // print("输入页号:")
    //lnumber =  Int(readLine()!) ?? page_length
    print("输入块号:")
    pnumber =  Int(readLine()!) ?? page_length
    
//    page[page_length].lnumber=page_length
//    page[page_length].write=0
//    page[page_length].pnumber=pnumber
    PageBlock.end?.pointee = pnumber
    PageBlock.end = PageBlock.end! + 1
    page_length += 1

}
    while(pnumber != -1)
page_length -= 1
Show()

var w = 0
while w==0 {
print("输入逻辑地址:")
print("物理地址为\(Switch(laddress: Int(readLine()!) ?? page_length))")
print("继续输入0，结束输入1或其他")
w =  Int(readLine()!) ?? 1
}





print("Hello, World!")

