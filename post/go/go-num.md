
## rand

  import "math/rand"

    //生成随机种子
    rand.Seed(time.Now().Unix())
    rand.Intn(5)
