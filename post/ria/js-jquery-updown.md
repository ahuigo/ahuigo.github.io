    <div id="updown">
        <div class="section">x0</div>
        <div class="section">x1</div>
    </div>
    $('#updown').fullpage({
        //sectionsColor : ['#1bbc9b', '#4BBFC3', '#7BAABE', '#CD853F'],
        continuousVertical: true,
        verticalCentered: true
    });

    setTimeout(function(){
        $.fn.fullpage.moveSectionDown();
    }, 3000);
