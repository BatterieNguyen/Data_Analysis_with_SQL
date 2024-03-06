Window functions 
* perform calculations that span multiple rows.
* have special syntax, including
    * `function name` - can be any normal aggregations (count // sum // avg // min // max) or special functions (rank // first_value // ntile)
    * `OVER` - determine the rows on which to operate.
    * `PARTITION BY` - include 0 or more fields.
      * When no fields are specified, the function operates over the entire table
      * When one or more field are speicfied, the function will operate only on that section of rows. 
    * `ORDER BY` - the order of opereated rows.

___Syntax___:
```
function(field_name) OVER (PARTITION BY field_name ORDER BY field_name)
```

