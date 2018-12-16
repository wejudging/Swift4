//
//  main.swift
//  混合索引组织
//
//  Created by wejudging on 2018/12/10.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation
//定义除去盘号盘块的大小，单位为B
let BLOCK_SIZE:Int = 16
//定义一个索引块中可以存放多少盘块
let MAX_NUMBER_IN_BLOCK:Int = 8
//定义盘块号的最大值
let MAX_BLOCK_NUMBER:Int = 1000

//定义一次间址的索引块、二次和三次间址的最后一层索引快
struct Index_block_three
{
    var blocks = [Int].init(repeating: 0, count: MAX_NUMBER_IN_BLOCK)
}

//定义二次间址的第一个索引块，和三次间址的第二个索引块
struct Index_block_two
{
    var blocks = [Index_block_three].init(repeating: i, count: MAX_NUMBER_IN_BLOCK)
    
}
let i:Index_block_three
//定义三次间址的第一个索引块

struct Index_block_one
{
    var blocks = [Index_block_two].init(repeating: ii, count: MAX_NUMBER_IN_BLOCK)
}
var ii:Index_block_two

//定义混合索引的数据结构
struct Index_File
{
    //文件大小
    var fileSize:Int=0
    //定义10个直接地址项
    var addr:[Int] = [Int].init(repeating:0, count: 10)
    //定义一次间址的地指项
    var addr10:Index_block_three?
    //定义二次间址的地址项
    var addr11:Index_block_two?
    
    //定义三次间址的地址项
    var addr12:Index_block_one?
}


//生成第三层索引，并并根据blocks赋值
func indexBlockThree(blocks: [Int],start:Int,end:Int) -> Index_block_three {
   var ans = Index_block_three.init()
   var j = 0
    for i in start..<end {
        ans.blocks[j] = blocks[i]
        j=j+1
        print(ans.blocks[j - 1])
    }
   return ans
}


//生成第二层索引
func indexBlockTwo(blocks: [Int],start:Int,end:Int) -> Index_block_two {
    //计算生成几个第三层索引
    let num:Int = (((end - start)%MAX_NUMBER_IN_BLOCK) == 0) ? ((end - start) / MAX_NUMBER_IN_BLOCK) : ((end - start)/MAX_NUMBER_IN_BLOCK + 1)
    //生成第二层索引
    var ans=Index_block_two.init()
    //生成num第三层索引
    for i in 0..<num {
        if i != (num-1){
            ans.blocks[i] = indexBlockThree(blocks: blocks, start: start + i * MAX_NUMBER_IN_BLOCK, end: start + (i + 1) * MAX_NUMBER_IN_BLOCK)}
        else {ans.blocks[i] = indexBlockThree(blocks: blocks, start: start + i * MAX_NUMBER_IN_BLOCK, end: end) }
    }
    
    return ans
}


//生成第二层索引
func indexBlockOne(blocks:[Int],start:Int,end:Int) -> Index_block_one {
    //计算二层索引块的个数
    let num:Int = (end - start) % (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK) == 0 ? (end - start) / (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK) : (end - start) / (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK) + 1
    var ans = Index_block_one.init()
    //生成num个二层索引的块
    for i in 0..<num {
        if i != num-1 {
            ans.blocks[i] = indexBlockTwo(blocks: blocks, start: start + i * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK, end: start + (i + 1) * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK)}
        else {
            ans.blocks[i] = indexBlockTwo(blocks: blocks, start: start + i * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK, end: end)}
    }
    return ans
    
    
}


//给定一个文件的长度，给出模拟分配占用的磁盘块的情况
func indexFile(filesize:Int) -> Index_File {
    print("文件大小为：\(filesize)")
    //计算该文件需要多少盘块
    let block_num = filesize % BLOCK_SIZE == 0 ? filesize / BLOCK_SIZE : filesize / BLOCK_SIZE + 1
    print("共占 \(block_num)个盘块")
    //定义保存所有盘块号的数组
    var blocks:[Int] = [Int].init(repeating: 0, count: block_num)
    //模拟系统分配空闲盘块号
    var flag = [Int: Int]()
    
    for i in 0..<block_num {
        var temp = Int(arc4random()) % MAX_BLOCK_NUMBER
        //flag[temp] = 0
        while flag[temp] != nil {
            temp = Int(arc4random()) % MAX_BLOCK_NUMBER
        }
        flag[temp] = 1
        blocks[i] = temp
    }
    
    var indexfile = Index_File.init()
    indexfile.fileSize=filesize
    
    //直接地址
    if block_num <= 10
    {
        print("直接盘块号为：")
        for i in 0 ..< block_num
        {
            indexfile.addr[i] = blocks[i]
            print(indexfile.addr[i])
        }
    }
    //一次间址
    else if block_num <= MAX_NUMBER_IN_BLOCK + 10{
        print("直接盘块号为：")
        for i in 0..<10
        {   indexfile.addr[i] = blocks[i]
            print(indexfile.addr[i])
        }
        print("一次间址盘块号为：")
        indexfile.addr10 = indexBlockThree(blocks: blocks, start: 10, end: block_num)
    }
    //二次间址
    else if block_num <= MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10
    {
        print("直接盘块号为：")
        for i in 0..<10
        {
            indexfile.addr[i] = blocks[i]
            print(indexfile.addr[i])
        }
        print("一次间址盘块号为：")
        indexfile.addr10 = indexBlockThree(blocks: blocks, start: 10, end: MAX_NUMBER_IN_BLOCK + 10)
        print("二次间址盘块号为：")
        indexfile.addr11 = indexBlockTwo(blocks: blocks, start: MAX_NUMBER_IN_BLOCK+10, end: block_num)
    }
    //三次间址
    else if block_num <= MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK + MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10
    {
        print("直接盘块号为：")
        for i in 0..<10
        {
            indexfile.addr[i] = blocks[i]
            print(indexfile.addr[i])
        }
        print("一次间址盘块号为：")
        indexfile.addr10 = indexBlockThree(blocks: blocks, start: 10, end: MAX_NUMBER_IN_BLOCK + 10)
        print("二次间址盘块号为：")
        
        indexfile.addr11 = indexBlockTwo(blocks: blocks, start: MAX_NUMBER_IN_BLOCK+10, end: MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10)
        print("三次间址盘块号为：");
        indexfile.addr12 = indexBlockOne(blocks: blocks, start: MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10, end: block_num)
    }
    else{var m = 0
         print("输入的文件太大，请重新输入！")
         print("输入文件大小：")
         m =  Int(readLine()!) ?? 0
         _ = indexFile(filesize: m)
    }
    
    return indexfile
}


//给定地址addrss和文件indexfile，找到地址对应的块号
func findBlock(  addrss1: Int , indexfile:Index_File) -> Int {
    var ans:Int = 0
    let addrss = addrss1 + 1
    var block_num = addrss % BLOCK_SIZE == 0 ? addrss / BLOCK_SIZE : addrss / BLOCK_SIZE + 1
    print("\(addrss - 1) 在第 \(block_num)个盘块")
    if block_num <= 10
    {
        ans = indexfile.addr[block_num - 1]
        print("在直接盘块号的第\(block_num)个")
    }
    //一次间址
    else if block_num <= MAX_NUMBER_IN_BLOCK + 10
    {
        block_num -= 10;
        //计算盘块号
        let index = block_num - 1;
        //查找盘块
        ans = indexfile.addr10!.blocks[index]
        
        print("在一次间址盘块号的第\(block_num)个")
    }
    //二次间址
    else if block_num <= MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK + MAX_NUMBER_IN_BLOCK + 10
    {
        block_num -= MAX_NUMBER_IN_BLOCK + 10
        //计算第三层索引块的序号
        let index_three = block_num % MAX_NUMBER_IN_BLOCK == 0 ? block_num / MAX_NUMBER_IN_BLOCK : block_num / MAX_NUMBER_IN_BLOCK + 1
        //计算盘块号
        let index = block_num - ((index_three - 1) * MAX_NUMBER_IN_BLOCK)
        //查找盘块
        ans = indexfile.addr11!.blocks[index_three - 1].blocks[index - 1]
      //  print((block_num-1)/MAX_NUMBER_IN_BLOCK + 1)
        print("在二次间址盘块号的第\((block_num-1)/MAX_NUMBER_IN_BLOCK + 1)个的一次间址盘块号的的第\((block_num-1)%MAX_NUMBER_IN_BLOCK+1)个")
    }
    //三次间址
    else if block_num <= MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK + MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10
    {
        block_num -= MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK + MAX_NUMBER_IN_BLOCK + 10
        //计算第二层索引块的序号
        let index_two = block_num % (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK) == 0 ?
            block_num / (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK) : block_num / (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK) + 1
        block_num -= (index_two - 1) * (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK);
        //计算第二层索引块的序号
        let index_three = block_num % MAX_NUMBER_IN_BLOCK == 0 ? block_num / MAX_NUMBER_IN_BLOCK : block_num / MAX_NUMBER_IN_BLOCK + 1
        //计算盘块号
        let index = block_num - (index_three - 1) * MAX_NUMBER_IN_BLOCK
        //查找盘块
        ans = indexfile.addr12!.blocks[index_two - 1].blocks[index_three - 1].blocks[index - 1]
        
        print("在三次间址盘块号的第\((block_num-1)/(MAX_NUMBER_IN_BLOCK*MAX_NUMBER_IN_BLOCK) + 1)个的二次间址盘块号的的第\((block_num-1)/MAX_NUMBER_IN_BLOCK+1)个的一次间址盘块号的的第\((block_num-1)%MAX_NUMBER_IN_BLOCK+1)个")
    }
    return ans
}



var x = 1 ,y = 1
print("最大文件大小")
print((MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK + MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10)*BLOCK_SIZE)
while x == 1 {
var n:Int=0,m:Int
print("输入文件大小：")
m =  Int(readLine()!) ?? 0
if m <= (MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK * MAX_NUMBER_IN_BLOCK + MAX_NUMBER_IN_BLOCK * (MAX_NUMBER_IN_BLOCK + 1) + 10)*BLOCK_SIZE{
let file = indexFile(filesize: m)
    
while y==1 {
    
print("输入地址")
n =  Int(readLine()!) ?? 0
    if  n > m{
        print("输入的地址有误，重新输入！")
        continue
        }
  y = 0
    
 }
print("\(n) 所在的盘块号为 \(findBlock(addrss1: n, indexfile: file))")
   
print("是否继续，继续任意输入，结束输入0")
x =  Int(readLine()!) ?? 1
y = 1
    }
else {print("输入的文件太大或者输入错误，请重新输入！")}
}


