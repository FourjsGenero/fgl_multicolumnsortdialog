-- type for each sort column, the name and whether reverse or not
PUBLIC TYPE column_list_type DYNAMIC ARRAY OF RECORD
    column_name STRING,
    reverse BOOLEAN
END RECORD

-- List of columns in table
DEFINE m_columns DYNAMIC ARRAY OF RECORD
    name STRING,
    text STRING
END RECORD



-- Intended call pattern
-- Note uses pass by refererence for l_column_list as dynamic array
-- CALL multicolumnsortwizard.execute("test", 3, l_column_list)
-- FOR i = l_column_list.getLength() TO 1 STEP -1
--    CALL arr.sort(l_column_list[i].column_name,  l_column_list[i].reverse)
-- END FOR



FUNCTION execute(l_table_name, l_max_columns, l_column_list)
DEFINE l_table_name STRING
DEFINE l_max_columns INTEGER
DEFINE l_column_list column_list_type

DEFINE l_fields DYNAMIC ARRAY OF RECORD
    name STRING,
    type STRING
END RECORD

DEFINE d ui.Dialog
DEFINE w ui.Window
DEFINE f ui.Form
DEFINE i INTEGER

DEFINE l_table_node, l_column_node om.DomNode
DEFINE l_fields_idx INTEGER

DEFINE l_column_name STRING
DEFINE l_reverse BOOLEAN

    LET w = ui.Window.getCurrent()
    LET f = w.getForm()

    LET l_table_node = f.findNode("Table", l_table_name)

    -- Populate list of columns
    LET l_column_node = l_table_node.getFirstChild()
    LET i = 1
    WHILE l_column_node IS NOT NULL
        LET m_columns[i].name = l_column_node.getAttribute("colName")
        LET m_columns[i].text = nvl(l_column_node.getAttribute("text"),l_column_node.getAttribute("colName"))
        LET l_column_node = l_column_node.getNext()
        LET i = i + 1
    END WHILE

    -- Populate fields array for dynamic dialog
    LET l_fields_idx= 0
    FOR  i = 1 TO l_max_columns
        LET l_fields_idx = l_fields_idx + 1
        LET l_fields[l_fields_idx].name = SFMT("column_%1", i USING "<<<")
        LET l_fields[l_fields_idx].type= "STRING"

        LET l_fields_idx = l_fields_idx + 1
        LET l_fields[l_fields_idx].name = SFMT("reverse_%1", i USING "<<<")
        LET l_fields[l_fields_idx].type= "BOOLEAN"
    END FOR
    
    OPEN WINDOW multicolumnsortwizard WITH 1 ROWS, 1 COLUMNS ATTRIBUTES(STYLE="dialog")
    CALL create_form(l_max_columns)
    
    LET d = ui.Dialog.createInputByName(l_fields)
    CALL d.addTrigger("ON ACTION accept")
    CALL d.addTrigger("ON ACTION cancel")
    -- Set reverse to false
    FOR i = 1 TO l_max_columns
        CALL d.setFieldValue(SFMT("reverse_%1", i USING "<<<"), false)
    END FOR
    WHILE TRUE
        CASE d.nextEvent()
            WHEN "BEFORE INPUT"
                MESSAGE "Select columns to sort by"
            WHEN "ON ACTION cancel"
                LET int_flag = TRUE
                EXIT WHILE
            WHEN "ON ACTION accept"
                CALL d.accept()
                EXIT WHILE
        END CASE
    END WHILE
    
    IF int_flag THEN
        LET int_flag = 0
    ELSE
        CALL l_column_list.clear()
        FOR i = 1 TO l_max_columns
            LET l_column_name = d.getFieldValue(SFMT("column_%1", i USING "<<<"))
            IF l_column_name IS NOT NULL THEN
                LET l_reverse = d.getFieldValue(SFMT("reverse_%1", i USING "<<<"))
                CALL l_column_list.appendElement()
                LET l_column_list[l_column_list.getLength()].column_name = l_column_name
                LET l_column_list[l_column_list.getLength()].reverse = l_reverse
            END IF
        END FOR
    END IF
    CALL d.close()
    CLOSE WINDOW multicolumnsortwizard
END FUNCTION



PRIVATE FUNCTION create_form(l_max_columns)
DEFINE l_max_columns INTEGER

DEFINE w ui.Window
DEFINE f ui.Form
DEFINE i,j INTEGER

DEFINE l_form_node, l_grid_node, l_label_node, l_form_field_node, l_widget_node, l_item_node om.DomNode
DEFINE l_tab_index INTEGER
    
    LET w = ui.Window.getCurrent()
    CALL w.setText("Multi Column Sort Dialog")

    LET f = w.createForm("multicolumnsortdialog")
    LET l_form_node = f.getNode()

    LET l_grid_node = l_form_node.createChild("Grid")
    
    -- create form with variable number of fields
    LET l_tab_index = 0
    FOR i = 1 TO l_max_columns
        LET l_label_node = l_grid_node.createChild("Label")
        CALL l_label_node.setAttribute("posX",1)
        CALL l_label_node.setAttribute("posY",i)
        CALL l_label_node.setAttribute("text",SFMT("Column %1", i USING "<<<"))

        LET l_tab_index = l_tab_index + 1
        LET l_form_field_node = l_grid_node.createChild("FormField")
        CALL l_form_field_node.setAttribute("colName",SFMT("column_%1", i USING "<<<"))
        CALL l_form_field_node.setAttribute("name",SFMT("formonly.column_%1", i USING "<<<"))
        CALL l_form_field_node.setAttribute("tabIndex",l_tab_index)

        LET l_widget_node = l_form_field_node.createChild("ComboBox")
        CALL l_widget_node.setAttribute("posX",11)
        CALL l_widget_node.setAttribute("posY",i)
        CALL l_widget_node.setAttribute("width",10)
        CALL l_widget_node.setAttribute("height","1")

        FOR j = 1 TO m_columns.getLength()
            LET l_item_node = l_widget_node.createChild("Item")
            CALL l_item_node.setAttribute("name",m_columns[j].name)
            CALL l_item_node.setAttribute("text",m_columns[j].text)
        END FOR

        LET l_tab_index = l_tab_index + 1
        LET l_form_field_node = l_grid_node.createChild("FormField")
        CALL l_form_field_node.setAttribute("colName",SFMT("reverse_%1", i USING "<<<"))
        CALL l_form_field_node.setAttribute("name",SFMT("formonly.reverse_%1", i USING "<<<"))
        CALL l_form_field_node.setAttribute("tabIndex",l_tab_index)
        CALL l_form_field_node.setAttribute("notNull", true)
        
        LET l_widget_node = l_form_field_node.createChild("CheckBox")
        CALL l_widget_node.setAttribute("posX",21)
        CALL l_widget_node.setAttribute("posY",i)
        CALL l_widget_node.setAttribute("width",3)
        CALL l_widget_node.setAttribute("height","1")
        CALL l_widget_node.setAttribute("text","Reverse")
    END FOR

    CALL l_form_node.setAttribute("width",25)
    CALL l_form_node.setAttribute("height",l_max_columns)
END FUNCTION