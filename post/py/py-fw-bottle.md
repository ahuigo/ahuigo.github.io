# Demo

    from bottle import run, get, static_file, redirect, template
    import logger

    @get('/')
    def index():
        tpl = '''
            <h2>{{title}} </h2>
            '''
        return template( tpl, title='title' )

    @get('/img/pic')
    def pic():
        return static_file('path/to/pic.png', root=".")

    @get('/redirect')
    def re_login():
        return redirect("/")

    def run_server(host="0.0.0.0", port=8999):
        run(host=host, port=port)
