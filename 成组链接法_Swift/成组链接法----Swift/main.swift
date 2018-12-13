//
//  main.swift
//  成组链接法----Swift
//
//  Created by wejudging on 2018/12/11.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation
//盘块的大小
let BLOCK_SIZE:Int = 4
//盘块分组大小
let GROUP_SIZE:Int = 3
//盘块数
let BLOCKNUM:Int = 7


struct Block {
    //指向栈底
    var base:UnsafeMutablePointer<Int>?
    //指向盘块号栈的顶部
    var top:UnsafeMutablePointer<Int>?
}


var m:Block=Block.init(base: UnsafeMutablePointer<Int>.allocate(capacity: BLOCK_SIZE*8), top: UnsafeMutablePointer<Int>.allocate(capacity: BLOCK_SIZE*8))

//定义内存盘块的堆栈
var MemoryBlock:Block = Block.init(base: UnsafeMutablePointer<Int>.allocate(capacity: BLOCK_SIZE*8), top: UnsafeMutablePointer<Int>.allocate(capacity: BLOCK_SIZE*8))
//定义全局的系统盘块数组
var DiskBlock:[Block] = [Block].init(repeating: m, count: BLOCKNUM)
//盘块分组的数量,随着分配和回收而可能发生动态变化
var GroupNumber:Int = 0
//分配和回收的算法共享Copy（）函数
var CopyPattern:Bool = true
//系统现有的空闲盘块数量（计数）
var SpareBlockNumber:Int = 0

//为盘块（包括内存盘块）分配空间，并进行部分初始化工作
func InitBlock(){
    for i in 0 ..< BLOCKNUM {
        DiskBlock[i].base = UnsafeMutablePointer<Int>.allocate(capacity: BLOCK_SIZE*8)
       // print(DiskBlock[i].base!)
        DiskBlock[i].top  = DiskBlock[i].base!+1
        //print(DiskBlock[i].top)
        DiskBlock[i].base?.pointee = 0
    }
    MemoryBlock.base = UnsafeMutablePointer<Int>.allocate(capacity: BLOCK_SIZE*8)
    MemoryBlock.top = MemoryBlock.base!+1
    MemoryBlock.base?.pointee = 0
    
}







//初始化系统磁盘的盘块的成组链接情况，这里为了简单直观起见，先按盘块号由小到大的顺序进行连接
func InitialAllocation() {
    //程序运行中可以动态从控制台进行修改（分配或者回收
    GroupNumber=0
    //空闲盘块的数目初始置为0
    SpareBlockNumber = 0
    for j in 0 ..< (BLOCKNUM % GROUP_SIZE == 0 ? BLOCKNUM/GROUP_SIZE : BLOCKNUM/GROUP_SIZE + 1){
       
        for i in 0 ..< GROUP_SIZE{
            if(j==0)
            {   MemoryBlock.top!.pointee = i
                MemoryBlock.top! += 1
                MemoryBlock.base!.pointee += 1
                //空闲盘块的数目加一
                SpareBlockNumber += 1
            }
            else
            {
            if j != (BLOCKNUM % GROUP_SIZE == 0 ? BLOCKNUM/GROUP_SIZE : BLOCKNUM/GROUP_SIZE + 1)-1
            {
            DiskBlock[(j-1)*GROUP_SIZE].top!.pointee = j*GROUP_SIZE+i
            DiskBlock[(j-1)*GROUP_SIZE].top! += 1
            DiskBlock[(j-1)*GROUP_SIZE].base!.pointee += 1
            //空闲盘块的数目加一
            SpareBlockNumber += 1
            }
                
            else{
                if BLOCKNUM % GROUP_SIZE > i{
                DiskBlock[(j-1)*GROUP_SIZE].top!.pointee = j*GROUP_SIZE+i
                DiskBlock[(j-1)*GROUP_SIZE].top! += 1
                DiskBlock[(j-1)*GROUP_SIZE].base!.pointee += 1
                //空闲盘块的数目加一
                SpareBlockNumber += 1
                }
                
                
                }
            
                
            }
            
        }
        GroupNumber += 1
    }
   
}


func Show()  {
    var FirstBlockID = 0 , GroupID = 0 , IsFirstGroup:Bool = true
    for _ in 0..<GroupNumber {
        if(IsFirstGroup)
        {
            MemoryBlock.top! = MemoryBlock.base!+1
            FirstBlockID = MemoryBlock.top!.pointee

            print("第 \(GroupID) 组有\(MemoryBlock.base!.pointee)个空闲块，如下：")
           
            for _ in 0..<MemoryBlock.base!.pointee
            {   print("\(MemoryBlock.top!.pointee)   ")
                MemoryBlock.top! += 1
            }
            IsFirstGroup=false;
            GroupID += 1
        }
        else
        {
            DiskBlock[FirstBlockID].top=DiskBlock[FirstBlockID].base!+1
            print("第 \(GroupID) 组有\(DiskBlock[FirstBlockID].base!.pointee)个空闲块，如下：")
            
            for _ in 0..<DiskBlock[FirstBlockID].base!.pointee
            {
            print("\(DiskBlock[FirstBlockID].top!.pointee)   ")
                DiskBlock[FirstBlockID].top! += 1}
            FirstBlockID = (DiskBlock[FirstBlockID].base!+1).pointee
            GroupID += 1
            
    }
    
}
  
}


//把当前组的最后剩下将要分配的的块的的内容复制到当前栈中 若是true就是回收时的复制
func Copy(CopyPattern:Bool,BlockID:Int) -> Bool {
    //把当前栈中的内容复制到回收的这个盘块中，然后将回收的盘块号写到栈中，并当前栈中的base所指的计数值置为1
    
    MemoryBlock.top=MemoryBlock.base
    DiskBlock[BlockID].top=DiskBlock[BlockID].base
    if CopyPattern
    {
        //这里因为要复制base所指的计数值，所以要增加一次（比GroupSize）循环
        for _ in 0 ..< GROUP_SIZE+1
        {//循环复制
         MemoryBlock.top!.pointee = DiskBlock[BlockID].top!.pointee
         DiskBlock[BlockID].top! += 1
         MemoryBlock.top! += 1
        }
        GroupNumber -= 1
    }
    else
    {   for _ in 0 ..< GROUP_SIZE+1
        {//循环复制
            DiskBlock[BlockID].top!.pointee = MemoryBlock.top!.pointee
        DiskBlock[BlockID].top! += 1
        MemoryBlock.top! += 1
        }
        GroupNumber += 1
        //处理内存栈，令top回到base的下一个位置
        MemoryBlock.top!=MemoryBlock.base!+1
        //将盘块号写到top所指的位置，并使top自增
        //将base所指的计数值置为1，表示当前组中有一个块
        MemoryBlock.top!.pointee=BlockID
        MemoryBlock.top! += 1
        MemoryBlock.base!.pointee=1
    }
    return true
}


//回收盘块的算法
func RevokeBlock(BlockID:Int)  {
    //内存盘块栈满
    if MemoryBlock.base!.pointee>=GROUP_SIZE
    {
        CopyPattern=false
        print(Copy(CopyPattern: CopyPattern, BlockID: BlockID))
        //空闲盘块的数目加一
        SpareBlockNumber += 1
    }
    else
    {   //将盘块号存入该栈（盘块）的top指针所指的单元里。并令top自增
        MemoryBlock.top!.pointee=BlockID
        MemoryBlock.top! += 1
        MemoryBlock.base!.pointee += 1
        //空闲盘块的数目加一
        SpareBlockNumber += 1
    }
    
    
 
}
//分配盘块
func AssignBlock() -> Int {
    var BlockID:Int
    //把要分配的盘块号存在BlockID里
    MemoryBlock.top! -= 1
    BlockID = MemoryBlock.top!.pointee
    
    //内存盘块栈里的最后一个盘块
    if MemoryBlock.base!.pointee==1
        {
            CopyPattern=true
            //调用复制函数用来把要分配的盘块里的信息复制到内存盘块栈MemoryBlock里
            print("目前只是最后一个盘块,调用复制函数用来把要分配的盘块里的信息复制到内存盘块栈MemoryBlock里\(Copy(CopyPattern:  CopyPattern, BlockID: BlockID))")
            //空闲盘块的数目减一
            SpareBlockNumber -= 1
        }
        else
        {
            MemoryBlock.base!.pointee -= 1
            //空闲盘块的数目减一
            SpareBlockNumber -= 1
        }
        return BlockID
}

InitBlock()
var t=true
var C:String?
var Number:Int?
InitialAllocation()
print("目前有 \(BLOCKNUM) 个空闲块 ")
print("初始化这 \(BLOCKNUM) 个空闲快如下：")
Show()
while(t)
{
    print("申请空闲块，输入“a”：")
    print("释放空闲块，输入“r”：")
    print("结束，输入”e“：")
    C =  String(readLine()!)
    if C=="e"
    {t=false}
    else if C == "a"
    {
        print("输入需要申请的空闲块数量：")
        print("注意申请的空闲块数量必须小于 \(SpareBlockNumber)")
        Number = Int(readLine()!) ?? 0
        print("申请的空闲块如下：")
        
        for _ in 0..<Number!{
        print("\(AssignBlock())   ") }
        print("目前剩余的\(SpareBlockNumber) 个空闲块如下： ")
        Show()
    }
    else if C == "r"
    {
        print("输入需要回收的空闲块数量：")
        Number = Int(readLine()!) ?? 0
        print("输入需要回收的空闲块")
        var ID:Int?
        for _ in 0..<Number!{
            ID = Int(readLine()!) ?? 0
            RevokeBlock(BlockID: ID!)
            
        }
        print("成功回收！")
        print("目前剩余的\(SpareBlockNumber) 个空闲块如下：")
        Show()
    }
}


print("Hello, World!")

