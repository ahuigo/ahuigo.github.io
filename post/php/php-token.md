# Preface

  $tokens = token_get_all('<?php echo; ?>'); /* => array(
                                                    array(T_OPEN_TAG, '<?php'),
                                                    array(T_ECHO, 'echo'),
                                                    ';',
                                                    array(T_CLOSE_TAG, '?>') ); */

  $tokens = token_get_all('/* comment */'); // => array(array(T_INLINE_HTML, '/* comment */'));
