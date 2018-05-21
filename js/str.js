/**
 * str_pad
 */
String.prototype.str_pad = function(len){
	//var ans = ('0000'+str).substring(str.length);
	var ans = Array(len-this.length+1).join('0')+this
	return ans;
}

/**
 * get_pos
 */
String.prototype.getColumnPos = function(m, i) {
       return this.split(m, i).join(m).length + m.length;
}
String.prototype.nthIndex = function(pat, n){
    var L= this.length, i= -1;
    while(n-- && i++<L){
        i= this.indexOf(pat, i);
        if (i < 0) break;
    }
    return i;
}
/*
String.prototype.str_repeat = function(n) {
        var ch=this, pad='';
		if(n<1) return this;
        while (true) {
         if (n & 1) {
          	pad += ch;
          }
          n >>= 1;
          ch += ch
          if(n<=0){break}
        }
        return pad;
    }
*/
