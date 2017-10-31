# fgl_multicolumnsortdialog
A dialog that can be used for multi-column sorting

This example was created on the plane from Cancun Mexico to Dallas Texas after the 2016 Worldwide Genero Developer conference.

It was based on a question from the floor on how to do multi-column sorting.

The intended usage of this dialog is

    IMPORT FGL multi_column_sort_dialog
    ...
    DEFINE l_column_list multi_column_sort_dialog.column_list_type 
    ...
    DISPLAY ARRAY array-name ...
        ON ACTION multi_sort ATTRIBUTES(TEXT="Multi Column Sort")
            CALL multi_column_sort_dialog.execute(name-of-table, max-number-of-columns-to-sort, l_column_list)
            FOR i = l_column_list.getLength() TO 1 STEP -1
                CALL array-name.sort(l_column_list[i].column_name,  l_column_list[i].reverse)
            END FOR
    
It will raise a dialog similar to ...

![MultiColumn Sort Dialog](https://user-images.githubusercontent.com/13615993/32205756-fc27c1a4-be55-11e7-8528-74c469220dd5.png)

... where the combobox is populated with the columns of the current table.  The user selects the columns they wish to sort on and the array.sort method is then called.  The sort method is called for each column requested in reverse order so as to break ties correctly.
