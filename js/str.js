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
String.prototype.get_pos = function(m, i) {
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
String.prototype.str_pad = function(ch, n) {
        var pad = '';
		n = n - this.length;
		if(n<1) return this;
        while (true) {
        	if (n & 1) {
          	pad += ch;
          }
          n >>= 1;
          if (n) ch += ch;
          else break;
        }
        return pad+this;
    }
*/
