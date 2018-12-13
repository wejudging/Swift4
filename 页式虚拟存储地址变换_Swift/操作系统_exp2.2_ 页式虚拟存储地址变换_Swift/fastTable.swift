//
//  fastTable.swift
//  操作系统_exp2.2_ 页式虚拟存储地址变换_Swift
//
//  Created by wejudging on 2018/12/9.
//  Copyright © 2018 wejudging. All rights reserved.
//

import Foundation
class LURCache {
    class CacheNode {
        var prev: CacheNode?
        var next: CacheNode?
        var data: Int?
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
    
    func get(key : String) -> Int? {
        let tmpNode = nodes[key]
        move2Head(node: tmpNode)
        return tmpNode?.data ?? 0
    }
    
    func put(key: String , anyO: Int){
        var tmpNode = nodes[key]
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
    /*
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
     */
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
    
    //真正建立联系的是node[...],firstnode,lastnode辅助
    private func move2Head(node: CacheNode!){
        if let n = node {
            if node === firstNode{
                return
            }
            
            if n.prev != nil {
                n.prev?.next = n.next
            }
            
            if n.next != nil{
                n.next?.prev = n.prev
            }
            
            if lastNode === node{
                lastNode  = n.prev
            }
            
            if firstNode != nil {
                n.next = firstNode
                firstNode?.prev = n
            }
            
            firstNode = node
            
            n.prev = nil
            
            if lastNode == nil{
                lastNode  = firstNode
            }
            
        }
        
        
        
    }
}
