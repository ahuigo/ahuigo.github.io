$(function() {
    $('body').ajaxError(function(event, request, settings, err) {
        console.log('ajax error',event);
    });
    $.ajaxSetup({
        cache: false
    });

    $.scrollUp({
        scrollName: 'scrollUp', // Element ID
        topDistance: '100', // Distance from top before showing element (px)
        topSpeed: 300, // Speed back to top (ms)
        animation: 'fade', // Fade, slide, none
        animationInSpeed: 200, // Animation in speed (ms)
        animationOutSpeed: 200, // Animation out speed (ms)
        scrollText: 'Top', // Text for element
        activeOverlay: false, // Set CSS color to display scrollUp active point, e.g '#00FFFF'
    });
	//ceshi

    var blog = {};
    blog.views = {};
    blog.helper = {};

    blog.helper.build_main_model = function(data) {
        var result = {};
        document.title = data.site_name;
        result.site_name = data.site_name;
        result.copyright = data.copyright;
        result.navlist = _.map(data.cates, function(cate) {
            return {
                link: '#cate/' + cate.name,
                text: cate.text
            };
        });
        return result;
    };

    blog.helper.build_sidebar_model = function(data, cate) {
        var result = {};
        result.months = _.map(data.tree, function(value, key) {
            return {
                month: value[0],
                articles: _.map(value[1], function(article) {
                    return {
                        link: article,
                        text: article.split('/')[article.split('/').length-1]
                    }
                })
            };
        });
        return result;
    };


    // 获取当前地址
    blog.helper.getHost = function(url) {
            var host = "null";
            if(typeof url == "undefined"
                            || null == url)
                    url = window.location.href;
            var regex = /.*\:\/\/([^\/]*).*/;
            var match = url.match(regex);
            if(typeof match != "undefined"
                            && null != match)
                    host = match[0];
            var urls = url.split("#show/");
            host = urls[0]+'show/';
            return host;
    }

    // 转化引擎
    blog.helper.markdown = new Showdown.converter();


    blog.helper.addpages = function(index,articles,_div){
        var el = document.createElement('ul');
        el.setAttribute('data-num-items', "10");
        el.setAttribute('data-excerpt-length',"70");
        el.setAttribute('data-show-title', "0");

    }

    //代码高亮
    blog.helper.highlight = function () {
        return $('pre code').each(function(i, e) {
            return hljs.highlightBlock(e, '    ');
        });
    }

    blog.views.Sidebar = Backbone.View.extend({
        template: $('#tpl-sidebar').html(),
        initialize: function(options) {
            this.model = options.model;
            _.bindAll(this, 'render');
        },
        render: function() {
            var html = Mustache.to_html(this.template, this.model);
            $(this.el).append(html);
            $(this.el).find('li').click(function(e) {
                e.stopPropagation();
                var $el = $('ul',this);
                $(this).parent().find('li > ul').not($el).slideUp();
                $el.stop(true, true).slideToggle(200);
            });
            $(this.el).find('li > ul > li').click(function(e) {
                e.stopImmediatePropagation();  
            });
            return this;
        }
    });


    blog.views.Article = Backbone.View.extend({
        initialize: function(options) {
            var that = this;
            this.article = options.article;

            _.bindAll(this, 'render');
            $.get('post/' + this.article + '.md', function(data) {
                if(data.substr(0,4) === '---\n'){
                    var pos = data.substr(0,300).nthIndex('---\n', 2)
                    data = data.substr(pos);
                }
                data = data.replace(/\n/g, '\t\n')
                that.model = data;
                that.render();
            });

        },
        render: function() {
            if(!this.model) return this;
            var html = blog.helper.markdown.makeHtml(this.model);

            $(this.el).html(html);
            blog.helper.highlight();
            document.querySelector('#toc').appendChild(createToc(this.el))
            $(this.el).find('a').each(function(){
                var href = this.getAttribute('href')
                if(href.substr(0,3)=='/p/'){
                    this.setAttribute('href', '#show/'+href.slice(3))
                }
            })
        }
    });


    blog.views.Main = Backbone.View.extend({
        el: $('.main-body'),
        template: $('#tpl-main').html(),
        initialize: function() {
            _.bindAll(this, 'render');
            _.bindAll(this, 'sync');
        },
        sync: function() {
            var that = this;
            $.getJSON('post/tree.json', function(data) {
                that.data = data;
                that.render();
            });
        },
        render: function() {
            if(!this.data) {
                this.sync();
                return this;
            }

            // 主页面
            var main_model = blog.helper.build_main_model(this.data);
            var main_html = Mustache.to_html(this.template, main_model);
            $(this.el).empty().append(main_html);

            //侧边栏
            var sidebar_mode = blog.helper.build_sidebar_model(this.data, this.cate);
            var sidebar_view = new blog.views.Sidebar({
                model: sidebar_mode
            });
            this.$(".sidebar-nav").empty().append(sidebar_view.render().el);

            if(this.cate) {
                loadingIndex = false;
                this.$('.navbar-inner .nav li a[href="#cate/' + this.cate + '"]').parent().addClass('active');
            }

            if(this.article!="index") {
                var article_view = new blog.views.Article({
                    article: this.article
                });

                loadingIndex = false;
                this.$(".article-content").empty().append(article_view.render().el);
            }


            if(this.article == "index") {
                this.$(".article-content").empty();
                curIndex = 0;
                hasShowedNum = 0;
                loadingIndex = true;

                blog.views.make_main_index(this.cate,this.data.tree,this.pagenum);

                blog.views.Pagebar = Backbone.View.extend({
                    template:$('#tpl-pagebar').html(),
                    initialize:function(options){
                        this.model = options.model;
                        _.bindAll(this,'render');
                    },
                    render:function(){
                        var html = Mustache.to_html(this.template, this.model);
                        
                        $(this.el).append(html);
                        return this;
                    }
                })
                //页码工具条
                var pagebar_view = new blog.views.Pagebar({
                    model: {
                        'pages': [,{'num':1},{'num':2}, {'num':4}],
                        'num_up':1,
                        'num_next':100
                    }
                });
                this.$(".pagebar").empty().append(pagebar_view.render().el);
            }

        }
    });

    //文章计数
    var curIndex = 0;
    var hasShowedNum = 0;
    var loadingIndex = false;
    var curCate ;
    var curArticles;
    var curPageNum = 1;
    var showArticleNum = 2;

    //首页展示
    blog.views.make_main_index = function addIndex(cate,articles,pagenum) {
        this.curCate = cate;
        this.curArticles = articles;

        if(loadingIndex){
            if(curIndex<showArticleNum*(pagenum-1)){
                curIndex = showArticleNum*(pagenum-1);
            }

            if(curIndex >= articles.length){
                return ;
            }

            $.get("post/" + articles[curIndex].file + ".md", function(artData) {

                var html;
                if(artData.length >= 200) {
                    html = blog.helper.markdown.makeHtml(artData.substring(0, 200));

                } else {
                    html = blog.helper.markdown.makeHtml(artData);
                }

                $(".article-content").append(html);

                //添加继续阅读
                $(".article-content").append("<br/>");
                $(".article-content").append("<p><a title=\"\" class=\"btn btn-primary pull-left\" href=\"#show/" + articles[curIndex].file + "\"  onclick=\"\">继续阅读  →</a> </p><br/> <br/>");
                $(".article-content").append("<div class=\"line_dashed\"></div>");

                //总索引
                curIndex++;
                 //显示文章计数
                if(curIndex < articles.length && hasShowedNum < 10) {
                    hasShowedNum ++;
                    addIndex(cate,articles);
                }
            });
        }
    }

    blog.App = Backbone.Router.extend({
        routes: {
            "": "index",
            "cate/:cate": "cate",
            "show/*article": "show",
            "page/:num":"page"
        },
        make_main_view: function(cate, article,pagenum) {
            if(!this.main) {
                this.main = new blog.views.Main();
            }
            this.main.cate = cate;
            this.main.article = article;
            this.main.pagenum = pagenum
            this.main.render();
        },
        index: function() {
            //this.make_main_view(null, 'index',1);
            this.make_main_view(null, 'c/c-terminal',1);
        },
        cate: function(cate) {
            this.make_main_view(cate, 'index',1);
        },
        show: function(p) {
            this.make_main_view(null, p,1);
            window.scrollTo(0,0)
        },
        page: function(num){
            console.log(num)
            this.make_main_view(null,'index',num);
        }
    });

    app = new blog.App();
    Backbone.history.start();
});
