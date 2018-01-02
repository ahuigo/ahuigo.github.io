# tick and after

  //send a channel tick every time
  tick := time.Tick(100 * time.Millisecond)
  //send a channel boom in a time
	boom := time.After(500 * time.Millisecond)

receive type is `%T=time.Time`:

  fmt.Println(<-tick)
  fmt.Println(<-boom)

## timer, 定时器
 定时器对象

  time.NewTimer(2*time.Second)
  <- timer.C
  time.NewTicker(2*time.Second)
  <- ticker.C

停止:

  timer.Stop()
  ticker.Stop()

for ticker

  ticker := time.NewTicker(time.Second)
  for t := range ticker.C {
      fmt.Println("Tick at", t)
  }

# time unit

  time.Second
  time.Millisecond
  time.Microsecond
  time.Nanosecond

# Sleep

	time.Sleep(100 * time.Millisecond)

# now

    time.Now()

## timestamp

    time.Now().Unix()

## weekday

  	time.Now().Weekday()
  1~7
  	time.Now().Weekday()
  6
  	time.Saturday

## duration
duration:

  t0 := time.Now()
  ...
  t1 := time.Now()
  t1.Sub(t0)

  T = time.Duration
  time.Duration(5)
  time.Duration(5) * time.Second
