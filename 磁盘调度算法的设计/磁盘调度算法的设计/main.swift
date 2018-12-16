//
//  main.swift
//  磁盘调度算法的设计
//
//  Created by wejudging on 2018/12/9.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation

//var NALL:Int = 0 , Limit:Int = 0 , Jage:Int = 0 , Aver:Float = 0
//存储需要调度的磁道号
var DiscLine:[Int] = [Int].init(repeating: 0, count: 10)
//最大磁盘号限制
var Limit = 0 , Hand = 0
var Length=0

//磁道方向
var Direction = 0


//初始化需要调度的磁道号
func InitDiscLine( ){
    print(" 请输入磁头起始位置")
    Hand = Int(readLine()!) ?? 0
    print(" 请输入磁盘请求序列长度")
    Length = Int(readLine()!) ?? 0
    print(" 请输入磁道方向 0 为磁道增加方向，1为磁道减小方向")
    Direction = Int(readLine()!) ?? 0
    print("随机生成\(Length)个磁道号请输入1，自定义请输入0")
    switch Int(readLine()!) ?? 1 {
    case 1 :
        print("输入最大磁盘号限制")
        let Limit = Int(readLine()!) ?? 200
        var flag = [Int: Int]()
        for i in 0..<Length {
            var temp = Int(arc4random()) % Limit
            //flag[temp] = 0
            while flag[temp] != nil {
                temp = Int(arc4random()) % Limit
            }
            flag[temp] = 1
            DiscLine[i] = temp
            }
    case 0 :
        var flag = [Int: Int]()
        for i in 0..<Length {
            print("输入第\(i)个磁道号！")
            var temp = Int(readLine()!) ?? 200
            //flag[temp] = 0
            while flag[temp] != nil {
                 print("输入错误或输入重复！")
                temp = Int(readLine()!) ?? 200
            }
            flag[temp] = 1
            DiscLine[i] = temp
            }
    default:
        print("输入错误！")
    }
}



func SSTF() {
   //冒泡排序
    var Temp=0 , k=1 , l=0
    for i in 0..<Length
    {for j in i..<Length
        {if(DiscLine[i]>DiscLine[j])
            {Temp=DiscLine[i]
             DiscLine[i]=DiscLine[j]
             DiscLine[j]=Temp}}}
    print("SSTF算法磁道的访问顺序为:")
    if Hand>=DiscLine[Length-1] {
    for i in (0..<Length).reversed(){
        print(DiscLine[i])
    }
        print("经过的磁道总数:\(Hand-DiscLine[0])")
        print("平均寻道长度:\((Double(Hand-DiscLine[0]))/Double(Length))")
    }
    else if Hand<=DiscLine[0]{
        for i in 0..<Length{
            print(DiscLine[i])
        }
        print("经过的磁道总数:\(DiscLine[Length-1]-Hand)")
        print("平均寻道长度:\((Double(DiscLine[Length-1]-Hand))/Double(Length))")
    }
    else{
        var all=0
       //确定当前磁道在已排的序列中的位置
        while(DiscLine[k]<Hand)
        {            k+=1
        }
        //l在磁头位置的前一个欲访问磁道
        l=k-1
        //k在磁头位置的后一个欲访问磁道
        while((l>=0)&&(k<Length))
        {
        if((Hand-DiscLine[l])<=(DiscLine[k]-Hand))//选择离磁头近的磁道
        {
            print(DiscLine[l])
            all+=Hand-DiscLine[l]
            Hand=DiscLine[l]
            l=l-1
        }
        else
        {
            print(DiscLine[k])
            all+=DiscLine[k]-Hand
            Hand=DiscLine[k]
            k=k+1
        }
        }
        if(l == -1)//磁头位置里侧的磁道已访问完
        {
            for j in k..<Length//访问磁头位置外侧的磁道
            {
                print(DiscLine[j])
            }
            all+=DiscLine[Length-1]-DiscLine[0]
        }
        if(k==Length)//磁头位置外侧的磁道已访问完
        {
            for j in (0..<k).reversed()//访问磁头位置里侧的磁道
            {
                print(DiscLine[j])
            }
            all+=DiscLine[Length-1]-DiscLine[0]
        }
        
        print("经过的磁道总数:\(all)");
        print("平均寻道长度:\(Double(all)/Double(Length))")
        }
}


func SCAN()  {
    
    //冒泡排序
    var Temp=0 , k=1 , l=0
    for i in 0..<Length
    {for j in i..<Length
    {if(DiscLine[i]>DiscLine[j])
    {Temp=DiscLine[i]
        DiscLine[i]=DiscLine[j]
        DiscLine[j]=Temp}}}
    print("SSTF算法磁道的访问顺序为:")
    if Hand>=DiscLine[Length-1] {
        for i in (0..<Length).reversed(){
            print(DiscLine[i])
        }
        print("经过的磁道总数:\(Hand-DiscLine[0])")
        print("平均寻道长度:\((Double(Hand-DiscLine[0]))/Double(Length))")
    }
    else if Hand<=DiscLine[0]{
        for i in 0..<Length{
            print(DiscLine[i])
        }
        print("经过的磁道总数:\(DiscLine[Length-1]-Hand)")
        print("平均寻道长度:\((Double(DiscLine[Length-1]-Hand))/Double(Length))")
    }
    else{
        
        //确定当前磁道在已排的序列中的位置
        while(DiscLine[k]<Hand)
        {            k+=1
        }
        //l在磁头位置的前一个欲访问磁道
        l=k-1
        //k在磁头位置的后一个欲访问磁道
        switch Direction{
        case 0:
            for i in k..<Length{
                print(DiscLine[i])
            }
            for i in (0...l).reversed(){
                print(DiscLine[i])
            }
            print("经过的磁道总数:\(2*DiscLine[Length-1]-Hand-DiscLine[0])")
            print("平均寻道长度:\((Double(2*DiscLine[Length-1]-Hand-DiscLine[0]))/Double(Length))")
        case 1:
            for i in (0...l).reversed(){
                print(DiscLine[i])
            }
            for i in k..<Length{
                print(DiscLine[i])
            }
            print("经过的磁道总数:\(DiscLine[Length-1]+Hand-2*DiscLine[0])")
            print("平均寻道长度:\((Double(DiscLine[Length-1]+Hand-2*DiscLine[0]))/Double(Length))")
            
        default: break
        }
    }
}



InitDiscLine()


print(" 请输入磁盘调度算法 0 为最短寻找时间优先算法SSTF，1为扫描算法SCAN")
var f = Int(readLine()!) ?? 0
switch f {
case 0:
    SSTF()
case 1:
    SSTF()
    
default:
   break
}

print("Hello, World!")

