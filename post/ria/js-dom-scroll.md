---
layout: page
title:
category: blog
description:
---
# Preface

# scroll toc

	$(window).load(function(){
		//store postion of title
		var scrollTop = [];
		$.each($('#menuIndex li a'),function(index,item){
		  var selector = $(item).attr('data-id');
		  var top = $(selector).offset().top;
		  scrollTop.push(top);
		});

		//scroll (scroll postion vs dom postion)
		$(window).scroll(function() {
		  setTimeout(function() {
			var nowTop = $(window).scrollTop();
			var length = scrollTop.length;
			var index;
			if(nowTop+60 > scrollTop[length-1]) {
			  index = length;
			} else {
			  for(var i=0; i < length; i++) {
				if(nowTop+60 <= scrollTop[i]) {
				  index = i;
				  break;
				}
			  }
			}
			$('#menuIndex li').removeClass('on');
			$('#menuIndex li').eq(index-1).addClass('on');
		  },100);
		});
		$(window).resize(function(){
		  $(window).trigger('scroll')
		});
	})
