IMPORT FGL multi_column_sort_dialog
IMPORT util



MAIN

DEFINE arr DYNAMIC ARRAY OF RECORD
    rowid INTEGER,
    string_col STRING,
    int_col INTEGER,
    date_col DATE
END RECORD
DEFINE i INTEGER

DEFINE l_column_list multi_column_sort_dialog.column_list_type

    CLOSE WINDOW SCREEN
    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP

    CALL ui.Interface.loadStyles("multi_column_sort_dialog")
    CALL ui.Interface.setText("Multi Column Sort Dialog Test")

    FOR i = 1 TO 100
        LET arr[i].rowid = i
        LET arr[i].string_col = ASCII(util.math.rand(26)+65)
        LET arr[i].string_col = arr[i].string_col, arr[i].string_col, arr[i].string_col, arr[i].string_col
        LET arr[i].int_col = util.Math.rand(10)
        LET arr[i].date_col = TODAY + (util.Math.rand(11)-5)
    END FOR
    
    OPEN WINDOW w WITH FORM "multi_column_sort_dialog_test"

    DISPLAY ARRAY arr TO scr.* ATTRIBUTES(UNBUFFERED)
        ON ACTION multi_sort ATTRIBUTES(TEXT="Multi Column Sort")
            CALL multi_column_sort_dialog.execute("test", 3, l_column_list)
            FOR i = l_column_list.getLength() TO 1 STEP -1
                CALL arr.sort(l_column_list[i].column_name,  l_column_list[i].reverse)
            END FOR
    END DISPLAY
END MAIN