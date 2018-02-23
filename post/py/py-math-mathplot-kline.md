
## kline k线

     pip3 install -e https://github.com/ahui132/mpl_finance

    from mpl_finance import candlestick_ohlc
    candlestick_ohlc(plt.gca(),[[d2num(timestamp),1,3,0.5,2]])

完整的example

    from pylab import *
    from matplotlib.dates import DateFormatter, WeekdayLocator, DayLocator, MONDAY, date2num as d2
    from datetime import datetime
    from mpl_finance import candlestick_ohlc
    # date2num = d.timestamp()/86400+719163.3333333334

    fig, ax = plt.subplots()
    ax.xaxis.set_major_locator(WeekdayLocator(MONDAY)) # 大刻度
    ax.xaxis.set_minor_locator(DayLocator()) # 小刻度
    ax.xaxis.set_major_formatter(DateFormatter('%b %d')) # 大刻度显示记号: e.g., Jan 12，
    # ax.xaxis.set_minor_formatter(DateFormatter('%m/%d %H:%M:%S')) # 小刻度显示记号

    dates = [datetime(year=2013, month=10, day=10),
            datetime(year=2013, month=11, day=10),
            datetime(year=2013, month=12, day=10),
            datetime(year=2014, month=1, day=10),
            datetime(year=2014, month=2, day=10)]
    dates = [d2(d) for d in dates]
    open_data = [33.0, 33.3, 33.5, 33.0, 34.1]
    high_data = [33.1, 33.3, 33.6, 33.2, 34.8]
    low_data = [32.7, 32.7, 32.8, 32.6, 32.8]
    close_data = [33.0, 32.9, 33.3, 33.1, 33.1]
    quotes = list(zip(dates, open_data, high_data, low_data, close_data,))

    candlestick_ohlc(plt.gca(),quotes, width=0.5)
    plt.gcf().autofmt_xdate()
    plt.show()
