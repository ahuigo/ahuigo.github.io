/**
 * Refer to: https://websemantics.github.io/gh-pages-spa/
 */

;(function(l, projectPages) {

    const u = new URL(location.href) 

   /* redirect all 404 trafic to index.html */
   function redirect() {
        const basePath = '/'+u.pathname.split('/')[1] 
       const pathname = u.pathname;
       const search = u.search.slice(1);
       const query = new URLSearchParams(search)
       query.set('.ghspa_path', pathname)
       u.pathname = basePath
       u.search = query
       window.location.replace(u)
   }

   /* resolve 404 redirects into internal routes */
   function resolve() {
     if (location.search) {
        const q = new URLSearchParams(location.search)
     const pathname = q.get('.ghspa_path')
       if (pathname) {
            q.delete('.ghspa_path')
           u.pathname= pathname
           u.search = q
         window.history.replaceState(null, null,u)
       }
     }
   }
  document.title === '404' ? redirect() : resolve()
})()


