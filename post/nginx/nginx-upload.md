# upload
add the following option to your NGINX ./configure command:

    --add-module=path/to/nginx_upload_module

nginx 提供了简单的upload

    location /upload {
        # Pass altered request body to this location
        upload_pass   /upload.php;

        # Store files to this directory
        # The directory is hashed, subdirectories 0 1 2 3 4 5 6 7 8 9 should exist
        upload_store /data/nginx/upload/image.huajiao.com/ 1;

        # Set specified fields in request body
        upload_set_form_field $upload_field_name.name "$upload_file_name";
        upload_set_form_field $upload_field_name.content_type "$upload_content_type";
        upload_set_form_field $upload_field_name.path "$upload_tmp_path";

        # Inform backend about hash and size of a file
        upload_aggregate_form_field "$upload_field_name.md5" "$upload_file_md5";
        upload_aggregate_form_field "$upload_field_name.size" "$upload_file_size";

        upload_pass_form_field "^submit$|^description$";

        upload_cleanup 400 404 499 500-505;
    }
