//
//  main.swift
//  操作系统exp2_swift
//
//  Created by wejudging on 2018/12/8.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation

class LURCache {
    class CacheNode {
        var prev: CacheNode?
        var next: CacheNode?
        var data: Any?
        var key     = ""
        deinit{
            print("\(self.key) is die")
        }
    }
    
    
    private var cacheSize                           = 0
    //字典
    lazy private  var nodes :[String: CacheNode]     = [:]
    private var currentSize                         = 0
    private var firstNode: CacheNode?
    private var lastNode: CacheNode?
    
    init(cacheSize :Int){
        self.cacheSize = cacheSize
    }
    
    func get(key : String) -> Any? {
        let tmpNode = nodes[key]
        move2Head(node: tmpNode)
        return tmpNode?.data ?? "没有找到对应的值"
    }
    
    func put(key: String , anyO: Any){
        //tmpNode为CacheNode类型
        //将key的值给tmpNode
        var tmpNode = nodes[key]
        //若key有值则为修改覆盖key原来的值，若key的值为nil则为插入新的值
        if nil == tmpNode {
            if currentSize >= cacheSize {
                removeLast()
            }
            currentSize=currentSize+1
            tmpNode = CacheNode()
        }
        tmpNode!.key = key
        tmpNode!.data = anyO
        move2Head(node: tmpNode!)
        nodes[key] = tmpNode
    }
 
    func remove(key : String) -> CacheNode?{
        let tmpNode = nodes[key]
        if let node = tmpNode {
            if node.prev != nil {
                node.prev?.next = node.next
            }
            if node.next != nil {
                node.next?.prev = node.prev
            }
            if lastNode === tmpNode{
                lastNode = tmpNode?.prev
            }
            
            if firstNode === tmpNode {
                firstNode = tmpNode?.next
            }
            nodes[key] = nil
            currentSize=currentSize-1
        }
        return tmpNode
    }
 
    //清空缓存
    func clear(){
        firstNode = nil
        lastNode = nil
        nodes.removeAll()
    }
    
    private func removeLast(){
        if let lastn = lastNode {
            nodes[lastn.key] = nil//从缓存中删除
            currentSize=currentSize-1
            if let lastPre = lastn.prev {
                lastPre.next = nil
            }else{
                firstNode = nil
            }
            lastNode = lastNode?.prev
        }
    }
    
    //真正建立联系的是node[...],firstnode,lastnode只是辅助
    //前四个if仅是为了在插入已满又想插入相同的keym，key的三种位置（2，3为同一中key在中间的那种情况）
    private func move2Head(node: CacheNode!){
        
        if let n = node {
            //等价于===”表示两个类类型（class type）的常量或者变量引用同一个类实例
            //判断插入或修改的node是否为第一个node，是的话直接返回，关系不变
            //print(node === firstNode)
            if node === firstNode{
                return
            }
            
            //第一次false
            // 把n抽出来然后放到第一个
            print(n.prev != nil)
            if n.prev != nil {
                n.prev?.next = n.next
            }
            
            // 把n抽出来然后放到第一个
            //第一次false
            print(n.next != nil)
            if n.next != nil{
                n.next?.prev = n.prev
            }
            
            
            //等价于===”表示两个类类型（class type）的常量或者变量引用同一个类实例
            //判断插入或修改的node是否为最后一个node，为最后一个的话把n的前一个变为最后一个
            // print(lastNode === node)
            if lastNode === node{
                lastNode  = n.prev //把n的前一个变为最后一个
            }
            
            
            
            
           
            //firstNode不为空则把n放firstnode前
            //第一次false只有第一次的时候不执行，每次把n放到firstnode前面
            if firstNode != nil {
                n.next = firstNode
                firstNode?.prev = n
            }
            
            //第一次从这里执行
            //第一个node
            firstNode = node//为了下次给别人看不影响结构，让别人知道fisrtNode是多少
            n.prev = nil
            
            //第一次true只有第一次的时候执行
            if lastNode == nil{
                lastNode  = firstNode
            }
            
        }
        
       
        
    }
}

var test = LURCache(cacheSize: 4)

test.put(key: "a", anyO: "1")
test.put(key: "2", anyO: "2")
test.put(key: "3", anyO: "3")
test.put(key: "4", anyO: "4")
test.put(key: "5", anyO: "5")
test.put(key: "3", anyO: "6")
//print(test.get(key: "1")!)
//print(test.get(key: "2")!)
//print(test.get(key: "3")!)
//print(test.get(key: "4")!)
//print(test.get(key: "5")!)

