//
//  main.swift
//  操作系统_exp1_swift
//
//  Created by wejudging on 2018/12/8.
//  Copyright © 2018 wejudging. All rights reserved.
//


var Max_source = 50 //最大进程数
var Max_process = 50 //最大资源数
class bank
{
    
    
    //可用资源数
    var available = [Int](repeating: 0, count: Max_source)
   
    //最大需求
    var max = [[Int]](repeating: [Int](repeating: 0, count: Max_source), count: Max_process)

    //已分配资源数
    var allocation = [[Int]](repeating: [Int](repeating: 0, count: Max_source), count: Max_process)

    //还需资源数
    var need = [[Int]](repeating: [Int](repeating: 0, count: Max_source), count: Max_process)
    
    //进程需要资源数
    var request = [[Int]](repeating: [Int](repeating: 0, count: Max_source), count: Max_process)

    //判断系统是否有足够的资源分配
    var finish = [Bool](repeating: true, count: Max_process)
    
    //记录序列
    var p = [Int](repeating: 0, count: Max_process)
    
    var m:Int = 0;//用来表示进程
    var n:Int = 0;//表示资源
   
    
     func Init() {
        print("请输入进程的数目：")
        m =  Int(readLine()!) ?? 0
        print("请输入资源的数目：")
        n =  Int(readLine()!) ?? 0
        print("请输入每个进程最多所需的各资源数，按照 \(m) X \(n) 矩阵格式输入")
        for i in 0..<m{
            for j in 0..<n{
            max[i][j] = Int(readLine()!) ?? 0}
        }
        print("请输入每个进程已分配的各资源数，按照 \(m) X \(n) 矩阵格式输入")
        for i in 0..<m{
            for  j in 0..<n{
                allocation[i][j] = Int(readLine()!) ?? 0
                need[i][j] = max[i][j] - allocation[i][j]
                //注意这里的need可能小于0；要进行报错并重新输入，可以用continue来跳出当前循环
                if (need[i][j] < 0)
                {
                    print("你输入的第\(i+1)个进程的第\(j+1)个资源数有问题！\n退出程序！")
                }
                }
                }
        print("请输入各个资源现有的数目")
        for i in 0..<n{
        available[i]=Int(readLine()!) ?? 0
    }
    }

    func Display(){
            print("系统可用的资源数为:")
            for i in 0..<n{
                print("资源 \(i)   \(available[i])")
            }
        
            print("各进程还需要的资源量：")
            
            for i in 0..<m{
               print("进程\(i)")
            for j in 0..<n{
                print("资源 \(j)        \(need[i][j])")
                
            }
        }
           print("各进程已经得到的资源:        ")
           for i in 0..<m{
               print("进程\(i)")
               for j in 0..<n{
                print("资源 \(j)        \(allocation[i][j])")
                }
                }
                }
    
    func Banker(){
        //cusneed表示资源进程号
        var cusneed = 0, flag = 0,again = 0
        while(true){
            self.Display()
            while (true)
            {
                print("请输入要申请的进程号")
                cusneed=Int(readLine()!) ?? 0
                if (cusneed > m)
                {
                    print("没有该进程，请重新输入")
                    continue;
                }
               print("请输入进程所请求的各资源数")
                for i in 0..<n{
                    request[cusneed][i] = Int(readLine()!) ?? 0
                }
                for i in 0..<n{
                    if (request[cusneed][i] > need[cusneed][i])
                    {
                       print("你输入的资源请求数超过进程数需求量！请重新输入")
                        continue;
                    }
                    if (request[cusneed][i] > available[i])
                    {
                        print("你输入的资源请求数超过系统当前资源拥有数！")
                        break;
                    }
                }
                break
            }
            /*上述是资源请求不合理的情况，下面是资源请求合理时则执行银行家算法*/
            for i in 0..<n{
                available[i] -= request[cusneed][i];//可用资源减去成功申请的
                allocation[cusneed][i] += request[cusneed][i];//已分配资源加上成功申请的
                need[cusneed][i] -= request[cusneed][i];//进程还需要的减去成功申请的
            }
            /*判断分配申请资源后系统是否安全，如果不安全则将申请过的资源还给系统*/
            if (Safe()){
                print("同意分配请求！")}
            else
            {
                print("你的请求被拒绝！ ！！")
                /*进行向系统还回资源操作*/
                for i in 0..<n{
                    available[i] += request[cusneed][i]
                    allocation[cusneed][i] -= request[cusneed][i]
                    need[cusneed][i] += request[cusneed][i]
                }
            }
            /*对进程的需求资源进行判断，是否还需要资源，简言之就是判断need数组是否为0*/
            for i in 0..<n{
                if (need[cusneed][i] <= 0){flag=flag+1}
            }
            if (flag == n)
            {
                for i in 0..<n{
                
                    available[i] += allocation[cusneed][i];
                    allocation[cusneed][i] = 0;
                    need[cusneed][i] = 0;
                }
                print("进程 \(cusneed) 占有的资源已释放！")
                flag = 0;
            }
            
            for i in 0..<n{
                finish[i] = false;}
            /*判断是否继续申请*/
            print("你还想再次请求分配吗？是请按1，否请按0")
            again = Int(readLine()!) ?? 0
            if (again == 1 )   {continue;}
         
            break;
        }
        
    }
        
    
    func Safe() -> Bool {
        var l = 0 , j1 = 0
        var work = [Int](repeating: 0, count: Max_source)
        /*对work数组进行初始化，初始化时和avilable数组相同*/
        for i in 0..<n{ work[i] = available[i]}
        /*对finish数组初始化全为false*/
        for i in 0..<m{ finish[i] = false}
       
        var ii = 0
        
        while(ii != m)
        {
            for i in 0..<m {
            if (finish[i] == true){
            continue
            }
            else
            {   j1 = 0
                for  j in 0..<n
                {
                    if (need[i][j] > work[j]){ break}
                    j1 = j1+1
                }
                
                if (j1 == n)
                {
                    finish[i] = true
                    for k in 0..<n{
                        work[k] += allocation[i][k]}
                    
                    p[l] = i;//记录进程号
                    l = l + 1
                    ii =  -1
                    
                }
                else {continue}
            }
                
            }
            ii = ii + 1
            

        }

            
        
        
        if (l == m)
        {
            print("系统是安全的")
            print("安全序列：")
           for i in 0..<l
            {
                print(p[i])
               
            }
           
            return true;
        }
        else{
            print("系统是不安全的")
            return false;
        }
    }
    
}

var  test = bank()
test.Init()
print(test.Safe())
test.Banker()


//let input =  readLine()?.split(separator: " ")



