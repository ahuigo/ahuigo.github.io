document.addEventListener('DOMContentLoaded', function(){
	function countdown(){
		if(countdown.seconds){
			countdown.seconds--;
		}else{
			countdown.seconds = Math.floor((new Date('January 1, 2070 00:00:00') - new Date)/1000);
		}
		var seconds = countdown.seconds;
		var Secs = Math.floor(seconds %60);
		var Mins = Math.floor(seconds %3600/60);
		var Hours = Math.floor(seconds %86400/3600);
		var Days = Math.floor(seconds %(30*86400)/86400);
		var Months = Math.floor(seconds %(365*86400)/86400/30);
		var Years = Math.floor(seconds/86400/365);

		var time = Years + '/' + Months +'/' + Days + ' ' + Hours + ':' + Mins + ':' + Secs;
		return time;
	}
	var cxt=document.getElementById("countdown").getContext("2d");
	cxt.fillStyle = "#999";
	cxt.font = "normal 15px Arial";
	setInterval(function(){
		cxt.clearRect(0,0,200, 20);
		cxt.fillText(countdown(), 0, 15);
	},1000);
});
