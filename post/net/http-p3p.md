IE 默认不允许iframe 种cookie, Firefox/Chrome 则默认允许(P3P)

    <iframe src="http://a.com/setcookie.php">

IE 的话, 必须在setcookie.php 中声明:

    Response.AddHeader("P3P", "CP=CAO PSA OUR");
