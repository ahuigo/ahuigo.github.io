---
title: Gonic Context
date: 2020-03-10
private: true
---
# Gonic Context
    ctx.Set(key:string, value:interface{})

    ctx.Get(key:string):interface{}
    ctx.GetString(key:string)
    ctx.GetInt(key:string)

# config:viper
	"github.com/spf13/viper"

    // LoadConfig 载入配置
    func LoadConfig(name string, paths ...string) {
        viper.SetConfigName(name)
        viper.AddConfigPath("config/")
        for _, configPath := range paths {
            viper.AddConfigPath(configPath)
        }
        err := viper.ReadInConfig() // Find and read the config file
        if err != nil {
            log.Fatal("fail to load config file:", err)
        }
    }

usage:

    viper.GetString("k1.k2")