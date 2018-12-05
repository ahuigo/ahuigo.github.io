# 时间管理工具
1. 双代号网络计划 (进度网络图)
https://www.jianshu.com/p/c94701d8bfd2

1. 双代号时标网络计划 
https://wenku.baidu.com/view/37e6b875960590c69fc37696.html

3. FS, SS, FF,SF
Finish-to-Start (FS)，把这个任务的开始日期和前提条件任务的结束日期对齐，一般用于串行的任务安排，前一个任务必须完成后才能启动下一个新任务
Start-to-Start (SS)，把这个任务的开始日期和前提条件任务的开始日期对齐，一般用于并行任务的安排，也可以一个任务启动后，第二个任务延后或提前数日启动。
Finish-to-Finish (FF)，把这个任务的结束日期和前提条件任务的结束日期对齐，可以用于协调任务的统一时间完成，这样可以定义好任务的开始时间
Start-to-Finish (SF)，把这个任务的结束日期和前提条件任务的开始日期对齐，或者说是前置任务开始的日期决定了后续任务的完成时间, 比如说前置任务是一个后续任务需要使用的资源，前置任务什么时候可以开始释放出来，这决定了后续任务什么时候才可以完成。如剪辑室可以使用的时间，决定了剪辑前的工作应该完成的时间；或者例如，建筑项目的屋架不是现场建造的。项目中有两个任务“交付屋架”和“装配屋顶”，“装配屋顶”任务要在“交付屋架”任务开始之后才能完成。

# 时间、成本
fee:10 12 Plan: 6 3
Bcwp(Budgeted Cost of Work performed): 10*3
Acwp(Actual Cost of Work Performed): 12*3
Bcws(Budgeted Cost of Work Scheduled): 10*6

CV: BCWP-ACWP(>0,费用剩余)
SV: BCWP-BCWS(>0,进度剩余)
CPI:BCWP/ACWP
SPI:BCWP/BCWS


