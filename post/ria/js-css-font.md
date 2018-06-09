# font
like bootstrap

    @font-face {
    font-family: 'Glyphicons Halflings';

    src: url('../fonts/glyphicons-halflings-regular.eot');
    src: url('../fonts/glyphicons-halflings-regular.eot?#iefix') format('embedded-opentype'),
    url('http://localhost:3000/static/fonts/glyphicons-halflings-regular.woff2') format('woff2'),
        url('../fonts/glyphicons-halflings-regular.svg#glyphicons_halflingsregular') format('svg');
    }
    .glyphicon {
    font-family: 'Glyphicons Halflings';
    }
    .glyphicon-plus:before {
    content: "\e008";
    }

    <span class="glyphicon glyphicon-user"></span>