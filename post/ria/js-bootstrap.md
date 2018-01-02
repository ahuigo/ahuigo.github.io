# metro css
http://metroui.org.ua/

# datepicker
https://bootstrap-datepicker.readthedocs.io/en/latest/

  $("#starttime").datetimepicker({
      format: "yyyy-mm-dd hh:ii",
      autoclose: true,
      pickerPosition: "bottom-left"
  });

  $("#startDate").datepicker({
      format: "yyyy-mm-dd",
      autoclose: true,
      pickerPosition: "bottom-left"
  });

# navbar
https://jsbin.com/seqola/2/edit?html,css,js,output
http://walle-web.io/docs/
see [js-lib/navbar](navbar/menu.html)


# text

    .text-danger
    .text-warnning

.close

    <a href="#" class="close" data-dismiss="alert" aria-label="close" title="close">×</a>

# alert

    .alert .alert-warning
    .alert .alert-danger

# form

    <form class="form" role="form"> #垂直
    <form class="form-inline" role="form"> ;# 内嵌
    <form class="form-horizontal" role="form"> #水平

    <form role="form">
       <div class="form-group">
         <label for="usr">Name:</label>
         <input type="text" class="form-control" id="usr">
       </div>
       <div class="form-group">
         <label for="pwd">Password:</label>
         <input type="password" class="form-control" id="pwd">
       </div>
       <button type="submit" class="btn btn-default">提交</button>
       <input type="submit" class="btn btn-default">
     </form>

## 对齐

<div class="form-group">
  <label for="lastname" class="col-sm-3 control-label">姓</label>
  <div class="col-sm-2">
     <input type="text" class="form-control col-sm-2" id="lastname"
        placeholder="请输入姓">
  </div>
</div>
<div class="form-group">
  <div class="col-sm-offset-2 col-sm-10">
     <div class="checkbox">
          test
     </div>
  </div>
</div>

col-sm-offset-<index> 相当于column-<index>
col-sm-<length>  列宽度

## input

    class="form-control input-large"

## table

    .table-striped
        Striped Rows, 条纹
    .table-bordered
    .table-hover
        hower rows
    .table-condensed tr td/th
        makes a table more compact by cutting cell padding in half(8px->5px):

### .table-responsive
768px width @media 自适应

    <div class="table-responsive">
        <table class="table">
        </table>
    </div>

or:
https://css-tricks.com/responsive-data-tables/
https://css-tricks.com/examples/ResponsiveTables/responsive.php

### Contextual Classes

    <tr class="success">
        <td>John</td>
        <td>Doe</td>
        <td>john@example.com</td>
      </tr>
      <tr class="danger">
        <td>Mary</td>
        <td>Moe</td>
        <td>mary@example.com</td>
      </tr>

class list:

    Class	Description
    .active	Applies the hover color to the table row or table cell
    .success	Indicates a successful or positive action
    .info	Indicates a neutral informative change or action
    .warning	Indicates a warning that might need attention
    .danger	Indicates a dangerous or potentially negative action

## btn

    class="btn btn-m blue"
    class="btn btn-warning"
    class="btn btn-primary"

## checkbox
https://vsn4ik.github.io/bootstrap-checkbox/


    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css">
    <script src="https://code.jquery.com/jquery-2.2.3.min.js" defer></script>
    <script src="dist/js/bootstrap-checkbox.min.js" defer></script>

Enable Bootstrap-checkbox via JavaScript:

    $(':checkbox').checkboxpicker();
