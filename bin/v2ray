#/usr/bin/env bash
#wget https://raw.githubusercontent.com/ahuigo/a/master/bin/v2ray -O ./v2ray
#chomd u+x ./v2ray
#./v2ray /path/to/v2ray.config
if [[ -x ~/Applications/v2ray/v2ctl ]];then
    kill $(cat ~/log/v2ray.pid)
	case "$1" in
		(stop)  ;;
		(restart | start | *) 
            if [[ -f "$1" ]]; then
                config="$1";
				config="$(cd "$(dirname "$config")"; pwd)/$(basename "$config")"
            else
				config=~/wk/conf/v2ray.config
            fi
			cd ~
            ~/Applications/v2ray/v2ray -config $config &
            echo $! > ~/log/v2ray.pid ;;
            #echo $! > ~/log/v2ray.pid && disown ;;
	esac
else
    echo "Install v2ray ......"
    echo "$ v2ray [CONFIG]"
    cd ~;
    mkdir log
    mkdir Applications/v2ray
    wget https://github.com/v2ray/v2ray-core/releases/download/v4.18.0/v2ray-macos.zip -O v2ray.zip
    unzip -x v2ray.zip -d Applications/v2ray
    chmod u+x Applications/v2ray/{v2ctl,v2ray}
fi
