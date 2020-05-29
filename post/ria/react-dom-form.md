---
title: react dom form
date: 2020-05-27
private: true
---
# react dom form

# select 
## select placeholder

    this.setState({value:""}) //default
    <select value={value}>
        <option key="key0" value='' disabled> placeholder</option>
    </select>

或者利用 renderValue

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