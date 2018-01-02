# try

## catch multiple exception in on clause
since java 7

    try{}
    catch( IOException | SQLException ex ) {
        e.printStackTrace();
    }
