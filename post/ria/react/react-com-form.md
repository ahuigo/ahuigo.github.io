---
title: react dom form
date: 2020-05-27
private: true
---
# react dom form

# select placeholder

    <style>
        select:invalid { color: gray; }
    </style>
    <form>
    <select required>
        <option value="" disabled selected hidden>Please Choose...</option>
        <option value="0">Open when powered (most valves do this)</option>
        <option value="1">Closed when powered, auto-opens when power is cut</option>
    </select>
    </form>

## antd的封装
或者利用antd renderValue(antd示例)

    <Select
        value={value}
        autoWidth
        renderValue={selected => {
            console.log(selected);
            if (!selected) return "Placeholder";
            else return selected;
        }}
    >
        <MenuItem key={unit} value={unit}>{unit}</MenuItem>
    </Select>

## multiple select placeholder
官方示例:

    <FormControl className={classes.formControl}>
        <InputLabel id="demo-mutiple-checkbox-label">Placeholder</InputLabel>
        <Select
          labelId="demo-mutiple-checkbox-label"
          id="demo-mutiple-checkbox"
          multiple
          value={personName}
          onChange={handleChange}
          input={<Input />}
          renderValue={(selected) => selected.join(', ')}
          MenuProps={MenuProps}
        >