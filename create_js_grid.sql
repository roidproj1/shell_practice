CREATE OR REPLACE PROCEDURE makejsbytable (
  p_table_name IN   VARCHAR2,
  h_table_name IN   VARCHAR2 DEFAULT 'LMS_C900'
) IS

  v_column_name   VARCHAR2(50);
  v_comments   	  VARCHAR2(1000);  
  v_data_length   NUMBER(10);  
  v_cnt           NUMBER(5);
  
--pk column
  CURSOR c_1 IS
  SELECT
    column_name
  FROM
    user_cons_columns
  WHERE
    constraint_name IN (
      SELECT
        constraint_name
      FROM
        user_constraints
      WHERE
        table_name = p_table_name
        AND constraint_type = 'P'
    )
  ORDER BY
    position;

--pk column, comment
  CURSOR cc_1 IS
  SELECT
    ucc.column_name column_name, utc.comments comments 
  FROM
    user_tab_columns ucc, user_col_comments utc
  WHERE
    ucc.table_name = utc.table_name 
    and ucc.column_name = utc.column_name
    and ucc.table_name = p_table_name
    and ucc.column_name IN (
      SELECT
        column_name
      FROM
        user_cons_columns
      WHERE
        constraint_name IN (
          SELECT
            constraint_name
          FROM
            user_constraints
          WHERE
            table_name = p_table_name
            AND constraint_type = 'P'
        )
    );
    

--all column
  CURSOR c_2 IS
  SELECT
    column_name, 
    data_length
  FROM
    user_tab_columns
  WHERE
    table_name = p_table_name
  ORDER BY
    column_id;

--all column except pk column

  CURSOR c_3 IS
  SELECT
    column_name
  FROM
    user_tab_columns
  WHERE
    table_name = p_table_name
    AND column_name NOT IN (
      SELECT
        column_name
      FROM
        user_cons_columns
      WHERE
        constraint_name IN (
          SELECT
            constraint_name
          FROM
            user_constraints
          WHERE
            table_name = p_table_name
            AND constraint_type = 'P'
        )
    );
    
--all column except pk column

  CURSOR cc_3 IS
  SELECT
    ucc.column_name column_name, utc.comments comments 
  FROM
    user_tab_columns ucc, user_col_comments utc
  WHERE
    ucc.table_name = utc.table_name 
    and ucc.column_name = utc.column_name
    and ucc.table_name = p_table_name
    and ucc.column_name NOT IN (
      SELECT
        column_name
      FROM
        user_cons_columns
      WHERE
        constraint_name IN (
          SELECT
            constraint_name
          FROM
            user_constraints
          WHERE
            table_name = p_table_name
            AND constraint_type = 'P'
        )
    );  

BEGIN
  dbms_output.enable('10000000000');
---------------------------------------------------------------------------
--   variable
---------------------------------------------------------------------------
  dbms_output.put_line('/************************************************');
  dbms_output.put_line(' variable - global');  
  dbms_output.put_line('***********************************************/'); 
  dbms_output.put_line(' ');
  dbms_output.put_line('var grid = null;');
  dbms_output.put_line('var selRowId = -1;');
  dbms_output.put_line('var targetUrl = getContextPath() + "/ajax/";');      
  dbms_output.put_line(' ');
  
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('	var str' || replace(initcap(v_column_name),'_', '') || ' = $("#s_' || lower(v_column_name) || '").val();');
    dbms_output.put_line('	if(str' || replace(initcap(v_column_name),'_', '') || ' == "") str' || replace(initcap(v_column_name),'_', '') || ' = null;');  

  	dbms_output.put_line(' ');
  END LOOP;
  CLOSE c_1; 
  
  dbms_output.put_line('/************************************************');
  dbms_output.put_line('* function');  
  dbms_output.put_line('************************************************/');    
  dbms_output.put_line(' ');

  dbms_output.put_line('  function initTest() {');
  dbms_output.put_line(' ');
  dbms_output.put_line('	const rowData = [{');

  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('		"' || lower(v_column_name) || '":"",');
  END LOOP;
  CLOSE c_2;
  
  dbms_output.put_line('	}];');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	grid.appendRow(rowData);');
  dbms_output.put_line('  }');
  dbms_output.put_line(' ');
  
---------------------------------------------------------------------------
-- function clearControl()  
---------------------------------------------------------------------------

  dbms_output.put_line('function clearControl() {');

  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('	$("#f_' || lower(v_column_name) || '").val("");');
  END LOOP;
  CLOSE c_2;
    
  dbms_output.put_line('}');  
  dbms_output.put_line(' ');
  
---------------------------------------------------------------------------
-- function getJsonSearchParam()
---------------------------------------------------------------------------  

  dbms_output.put_line('function getJsonSearchParam() {');

  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('	var str' || replace(initcap(v_column_name),'_', '') || ' = $("#s_' || lower(v_column_name) || '").val();');
    dbms_output.put_line('	if(str' || replace(initcap(v_column_name),'_', '') || ' == "") str' || replace(initcap(v_column_name),'_', '') || ' = null;');  

  	dbms_output.put_line(' ');
  END LOOP;
  CLOSE c_1;

  dbms_output.put_line('	//// '|| upper(p_table_name) || '.selectList');
  dbms_output.put_line('	var pObj = {');
  dbms_output.put_line('		"qt" : qtselectList,'); 
  dbms_output.put_line('		"mi" : "' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.selectList'))) || '",');    
  dbms_output.put_line('		"map" : {');

  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('			"s_' || lower(v_column_name) || '" : str' || replace(initcap(v_column_name),'_', '') || ',');  
  END LOOP;
  CLOSE c_1;
  dbms_output.put_line('		}');    
  dbms_output.put_line('	};');
  dbms_output.put_line('	return encodeURIComponent(encodeURIComponent(JSON.stringify(pObj)));');    
  
  dbms_output.put_line('}');  
  dbms_output.put_line(' ');


---------------------------------------------------------------------------
-- function getSaveParam()
--------------------------------------------------------------------------- 

  dbms_output.put_line('function getJsonSaveParam(){');
  dbms_output.put_line('	var mRows = grid.getModifiedRows();');
  dbms_output.put_line('	var mIstRows = mRows.createdRows;');
  dbms_output.put_line('	var mUdtRows = mRows.updatedRows;');  

  dbms_output.put_line('	// return -1; //오류 일때 처리용');

  dbms_output.put_line('	var pList = [];');
  
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('	var str' || replace(initcap(v_column_name),'_', '') || ' = "";');
  END LOOP;
  CLOSE c_1;

  dbms_output.put_line('	var mi = null;');

-- insert

  dbms_output.put_line('	//// ' || upper(p_table_name) || '.insert');
  dbms_output.put_line('	mi = "' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.insert'))) || '";');    
  dbms_output.put_line(' ');
  
  dbms_output.put_line('	for(var i=0; i<mIstRows.length; i++)');
  dbms_output.put_line('	{');
  
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('		str' || replace(initcap(v_column_name),'_', '') || ' = mIstRows[i]["' || lower(v_column_name) || '"];');
  END LOOP;
  CLOSE c_1;  
  
  dbms_output.put_line('		pList.push({"qt" : qtInsert, "mi" : mi,'); 
  dbms_output.put_line('			"map" : { ');
  
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('				"' || lower(v_column_name) || '" : str' || replace(initcap(v_column_name),'_', '') || ',');
  END LOOP;
  CLOSE c_1;
  
  OPEN c_3;
  LOOP
    FETCH c_3 INTO v_column_name;
    EXIT WHEN c_3%notfound;
    dbms_output.put_line('				"' || lower(v_column_name) || '" : mIstRows[i]["' || lower(v_column_name) || '"],');
  END LOOP;
  CLOSE c_3;  

  dbms_output.put_line('				"tbl_id"   : "' || upper(p_table_name) || '",');
  dbms_output.put_line('				"tbl_pk"   : str' || replace(initcap(v_column_name),'_', '') || ',');
  dbms_output.put_line('				"callback" : "fn_saveSuccess"');
  dbms_output.put_line('			}');
  dbms_output.put_line('		});');
  dbms_output.put_line(' ');
  
  dbms_output.put_line('		pList.push({"qt" : qtInsert, "mi" : "' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw( upper(h_table_name) || '.insert' ))) || '",');  
  dbms_output.put_line('			"map" : { ');  
  dbms_output.put_line('				"tbl_id"   : "' || upper(p_table_name) || '",');
  dbms_output.put_line('				"tbl_pk"   : str' || replace(initcap(v_column_name),'_', '') || ',');
  dbms_output.put_line('				"callback" : "fn_saveSuccess",');    
  dbms_output.put_line('				"callfile" : "N",');  
  dbms_output.put_line('			}');
  dbms_output.put_line('		});');
  dbms_output.put_line('	}');
  dbms_output.put_line(' ');

    
-- update

  dbms_output.put_line('	//// ' || upper(p_table_name) || '.update');
  dbms_output.put_line('	mi = "' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.update'))) || '";');    
  dbms_output.put_line(' ');
  
  dbms_output.put_line('	for(var i=0; i<mUdtRows.length; i++)');
  dbms_output.put_line('	{');
  
  dbms_output.put_line('		pList.push({"qt" : qtUpdate, "mi" : mi,'); 
  dbms_output.put_line('			"map" : { ');
  
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('				"' || lower(v_column_name) || '" : mUdtRows[i]["' || lower(v_column_name) || '"],');
  END LOOP;
  CLOSE c_1;
  
  OPEN c_3;
  LOOP
    FETCH c_3 INTO v_column_name;
    EXIT WHEN c_3%notfound;
    dbms_output.put_line('				"' || lower(v_column_name) || '" : mUdtRows[i]["' || lower(v_column_name) || '"],');
  END LOOP;
  CLOSE c_3;  

  dbms_output.put_line('				"tbl_id"   : "' || upper(p_table_name) || '",');
  dbms_output.put_line('				"tbl_pk"   : str' || replace(initcap(v_column_name),'_', '') || ',');
  dbms_output.put_line('				"callback" : "fn_saveSuccess"');
  dbms_output.put_line('			}');
  dbms_output.put_line('		});');
  dbms_output.put_line(' ');
  
  dbms_output.put_line('		pList.push({"qt" : qtInsert, "mi" : "' 
                      || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw( upper(h_table_name) || '.insert' ))) 
                      || '",');  
  dbms_output.put_line('			"map" : { ');  
  dbms_output.put_line('				"tbl_id"   : "' || upper(p_table_name) || '",');
  dbms_output.put_line('				"tbl_pk"   : str' || replace(initcap(v_column_name),'_', '') || ',');
  dbms_output.put_line('				"callback" : "fn_saveSuccess",');    
  dbms_output.put_line('				"callfile" : "N",');  
  dbms_output.put_line('			}');
  dbms_output.put_line('		});');
  dbms_output.put_line('	}');
  dbms_output.put_line(' ');
  
  dbms_output.put_line('	var pObj = {"qt":qtBatch, "pList":pList, "mi":mi};');
  dbms_output.put_line(' ');
  dbms_output.put_line('	return encodeURIComponent(encodeURIComponent(JSON.stringify(pObj)));');  
  
  dbms_output.put_line('}');
  dbms_output.put_line(' ');

---------------------------------------------------------------------------
-- function saveAll()
---------------------------------------------------------------------------
  dbms_output.put_line('function saveAll(mRows) {');
  dbms_output.put_line('	var param = getJsonSaveParam();');
  dbms_output.put_line(' ');
  dbms_output.put_line('	// getJsonSaveParam에서 오류시 -1 리턴하도록 처리해뒀을 경우');  
  dbms_output.put_line('	if(param == "-1") {');
  dbms_output.put_line('		cAlert("E","계약번호 생성에 실패했습니다. 다시 시도해주시기 바랍니다.");');
  dbms_output.put_line('		return;');    
  dbms_output.put_line('	}'); 
  dbms_output.put_line(' ');
  dbms_output.put_line('	$.ajax({');
  dbms_output.put_line('		type : "post",');
  dbms_output.put_line('		dataType: "json",');
  dbms_output.put_line('		async : true,');
  dbms_output.put_line('		url : targetUrl,');
  dbms_output.put_line('		data : "pJson=" + param,');
  dbms_output.put_line('		success : function(data) {');
  dbms_output.put_line('			cAlert("S");');
  dbms_output.put_line('			btnSearchClicked();');
  dbms_output.put_line('		},');
  dbms_output.put_line('		error : function(data, status, err) {');
  dbms_output.put_line('			cAlert("E",err);');
  dbms_output.put_line('		}');
  dbms_output.put_line('	});');
  dbms_output.put_line(' ');
  dbms_output.put_line('}');      
  dbms_output.put_line(' ');
  
  dbms_output.put_line('function fn_saveSuccess(data) {');
  dbms_output.put_line('	cAlert("S");');
  dbms_output.put_line('	btnSearchClicked();');
  dbms_output.put_line('}');  
  dbms_output.put_line(' ');
  
---------------------------------------------------------------------------
-- function getJsonDeleteParam()
---------------------------------------------------------------------------

  dbms_output.put_line('function getJsonDeleteParam(strPkId){');
  dbms_output.put_line('	var pList = [];');
  dbms_output.put_line('	//// ' || upper(p_table_name) || '.delete');  
  dbms_output.put_line('	pList.push({"qt" : qtDelete,'); 
  dbms_output.put_line('		"mi" : "' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw( upper(h_table_name) ||  '.insert' ))) || '",');
  dbms_output.put_line('		"map" : {');
  
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('			"' || lower(v_column_name) || '" : strPkId,');
  END LOOP;
  CLOSE c_1;  
  
  dbms_output.put_line('		}');
  dbms_output.put_line('	});');
  dbms_output.put_line(' ');  
  dbms_output.put_line('	// 테이블 정보변경에 입력하기');
  dbms_output.put_line('	pList.push({"qt" : qtInsert, "mi" : "' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw( upper(h_table_name) ||  '.insert' ))) || '",');  
  dbms_output.put_line('		"map" : { ');  
  dbms_output.put_line('			"tbl_id"   : "' || upper(p_table_name) || '",');
  dbms_output.put_line('			"tbl_pk"   : strPkId,');
  dbms_output.put_line('			}');
  dbms_output.put_line('		});');
	
  dbms_output.put_line('	var pObj = {"qt":qtBatch, "pList":pList};');
  dbms_output.put_line(' ');
  dbms_output.put_line('	return encodeURIComponent(encodeURIComponent(JSON.stringify(pObj)));');
  dbms_output.put_line('}');      
  dbms_output.put_line(' ');

---------------------------------------------------------------------------
-- function deleteAction()
---------------------------------------------------------------------------
  
  dbms_output.put_line('function deleteAction(strPkId){');
  dbms_output.put_line('	$.ajax({');
  dbms_output.put_line('		type : "post",');
  dbms_output.put_line('		dataType: "json",');
  dbms_output.put_line('		async : true,');
  dbms_output.put_line('		url : targetUrl,');
  dbms_output.put_line('		data : "pJson=" + getJsonDeleteParam(strPkId),');
  dbms_output.put_line('		success : function(data) {');
  dbms_output.put_line('			cAlert("D");');
  dbms_output.put_line('			btnSearchClicked();');
  dbms_output.put_line('		},');
  dbms_output.put_line('		error : function(data, status, err) {');
  dbms_output.put_line('			cAlert("E",err);');
  dbms_output.put_line('		}');
  dbms_output.put_line('	});');
  dbms_output.put_line('}  ');
  dbms_output.put_line(' ');
  
---------------------------------------------------------------------------
-- function checkLength()
---------------------------------------------------------------------------

  dbms_output.put_line('function checkLength(){');
  dbms_output.put_line('	var mRows    = grid.getModifiedRows();');
  dbms_output.put_line('	var mIstRows = mRows.createdRows;');
  dbms_output.put_line('	var mUdtRows = mRows.updatedRows;');

  dbms_output.put_line('	//// check');
  dbms_output.put_line('	var strLengthColumn   = "";');
  dbms_output.put_line('	var strLengthName     = ""');
	
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('			+ "' || lower(v_column_name) || '|"');
  END LOOP;
  CLOSE c_2;	
  
  dbms_output.put_line('	;');
  dbms_output.put_line(' ');  
	
  dbms_output.put_line('	for(var i=0; i<mIstRows.length; i++)');
  dbms_output.put_line('	{');
  dbms_output.put_line('		strLengthColumn   ='); 
  
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('			mIstRows[i].' || lower(v_column_name) || ' + ",' || v_data_length || '|"');
  END LOOP;
  CLOSE c_2;
  
  dbms_output.put_line('			;');
  dbms_output.put_line('		if(!gfn_gridLengthCheck(strLengthColumn,strLengthName)) return false;');
  dbms_output.put_line('	}');
  dbms_output.put_line(' ');  
  dbms_output.put_line('	for(var i=0; i<mUdtRows.length; i++)');
  dbms_output.put_line('	{');	
  dbms_output.put_line('		strLengthColumn   =');
  
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('			mUdtRows[i].' || lower(v_column_name) || ' + ",' || v_data_length || '|"');
  END LOOP;
  CLOSE c_2;
  
  dbms_output.put_line('			;');
  dbms_output.put_line('		if(!gfn_gridLengthCheck(strLengthColumn,strLengthName)) return false;');
  dbms_output.put_line('	}');
  dbms_output.put_line(' ');  
	
  dbms_output.put_line('	return true;');
  dbms_output.put_line('}');

---------------------------------------------------------------------------
-- function  btnSearchClicked()  
---------------------------------------------------------------------------    
  dbms_output.put_line('function btnSearchClicked() {');
  dbms_output.put_line('	$.ajax({');
  dbms_output.put_line('		type : "post",');    
  dbms_output.put_line('		dataType : "json",');  
  dbms_output.put_line('		async : true,');
  dbms_output.put_line('		url : targetUrl,');
  dbms_output.put_line('		data : "pJson=" + getJsonSearchParam(),');
  dbms_output.put_line('		success : function(data) {');
  dbms_output.put_line('			grid.setData(data);');
  dbms_output.put_line('			if(data.length > 0){');
  dbms_output.put_line('				grid.focusAt(0,0,true);');    
  dbms_output.put_line('				selRowId = grid.getFocusedCell().rowKey;');
  dbms_output.put_line('				bindControlByGrid(grid.getFocusedCell().rowKey);');
  dbms_output.put_line('			} else {');
  dbms_output.put_line('				selRowId = -1;');
  dbms_output.put_line('			}');
  dbms_output.put_line('		},');
  dbms_output.put_line('		error : function(data, status, err) {');
  dbms_output.put_line('			cAlert("e",err);');        
  dbms_output.put_line('		}');
  dbms_output.put_line('	});');  
  dbms_output.put_line('}');  
  dbms_output.put_line(' ');  
  
  dbms_output.put_line('/************************************************');
  dbms_output.put_line('* bind');  
  dbms_output.put_line('************************************************/');
  dbms_output.put_line(' ');
  
---------------------------------------------------------------------------
-- function  bindControlByGrid(RowId)  
---------------------------------------------------------------------------

  dbms_output.put_line('function bindControlByGrid(RowId) {');

  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('	$("#f_'|| lower(v_column_name) || '").val(grid.getValue(RowId,"' || lower(v_column_name) || '",false));');
  END LOOP;
  CLOSE c_1;
    
  dbms_output.put_line('}');  
  dbms_output.put_line(' ');


  dbms_output.put_line('/************************************************');
  dbms_output.put_line('* event');  
  dbms_output.put_line('************************************************/');
  dbms_output.put_line(' ');

---------------------------------------------------------------------------
-- functions    
---------------------------------------------------------------------------

  OPEN cc_1;
  LOOP
    FETCH cc_1 INTO v_column_name, v_comments;
    EXIT WHEN cc_1%notfound;
    dbms_output.put_line('function ' || lower(v_column_name) || '_changeEvent(e)	{if(selRowId > -1) grid.setValue(selRowId, "' || lower(v_column_name) || '", $("f_' || lower(v_column_name) || '").val());} //' || v_comments );
  END LOOP;
  CLOSE cc_1;

  OPEN cc_3;
  LOOP
    FETCH cc_3 INTO v_column_name, v_comments;
    EXIT WHEN cc_3%notfound;
    dbms_output.put_line('function ' || lower(v_column_name) || '_changeEvent(e)	{if(selRowId > -1) grid.setValue(selRowId, "' || lower(v_column_name) || '", $("f_' || lower(v_column_name) || '").val());} //' ||  v_comments );
  END LOOP;
  CLOSE cc_3;

---------------------------------------------------------------------------
-- function  btnSearch_clickEvent(e)  
---------------------------------------------------------------------------    

  dbms_output.put_line('function btnSearch_clickEvent(e) {');
  dbms_output.put_line('	e.preventDefault();');
  dbms_output.put_line('	btnSearchClicked();');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');

---------------------------------------------------------------------------
-- function  btnSave_clickEvent(e)  
---------------------------------------------------------------------------    

  dbms_output.put_line('function btnSave_clickEvent(e) {');
  dbms_output.put_line('	e.preventDefault();');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	if(!(grid.isModified()) ){');
  dbms_output.put_line('		cAlert("N");');
  dbms_output.put_line('		return;');
  dbms_output.put_line('	}');
  dbms_output.put_line(' ');		
  dbms_output.put_line('	//필수항목체크');	
  dbms_output.put_line('	//if(!(checkData()) ){ return; } ');
  dbms_output.put_line(' ');
  dbms_output.put_line('	//길이체크');
  dbms_output.put_line('	if (!checkLength()) return;');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	var mRows    = grid.getModifiedRows();');
  dbms_output.put_line('	var mIstRows = mRows.createdRows;');
  dbms_output.put_line('	var mUdtRows = mRows.updatedRows;');
  dbms_output.put_line(' ');		
  dbms_output.put_line('	var vConf = "추가:"+mIstRows.length + " 수정:" + mUdtRows.length;');
  dbms_output.put_line(' ');			
  dbms_output.put_line('	swal({');
  dbms_output.put_line('		title : "저장",');
  dbms_output.put_line('		text : vConf,');
  dbms_output.put_line('		type : "warning",');
  dbms_output.put_line('		showCancelButton : true,');
  dbms_output.put_line('		confirmButtonColor : "#DD6B55",');
  dbms_output.put_line('		confirmButtonText : "저장",');
  dbms_output.put_line('		cancelButtonText : "취소",');		        
  dbms_output.put_line('		closeOnConfirm : false');
  dbms_output.put_line('		},');
  dbms_output.put_line('		function () {');
  dbms_output.put_line('			saveAll(mRows);');
  dbms_output.put_line('	});');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');	  

---------------------------------------------------------------------------
-- function  btnAdd_clickEvent(e)  
---------------------------------------------------------------------------   

  dbms_output.put_line('function btnAdd_clickEvent(e) {');
  dbms_output.put_line('	e.preventDefault();');
  dbms_output.put_line('	clearControl();');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	var addIndexPos = grid.getIndexOfRow(selRowId) + 1;');
  dbms_output.put_line('	var options     = {focus:true,at:addIndexPos};');
  dbms_output.put_line('	var newData     = {');
  
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('			' || lower(v_column_name) || ' : "",');
  END LOOP;
  CLOSE c_2;
			           
  dbms_output.put_line('	};');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	grid.appendRow(newData,options);');
  dbms_output.put_line('	selRowId = grid.getFocusedCell().rowKey;');
  dbms_output.put_line('	bindControlByGrid(grid.getFocusedCell().rowKey);');
  dbms_output.put_line(' ');	
  dbms_output.put_line('}');
  dbms_output.put_line(' ');

---------------------------------------------------------------------------
-- function  btnDel_clickEvent(e)  
---------------------------------------------------------------------------   
  
  dbms_output.put_line('function btnDel_clickEvent(e) {');
  dbms_output.put_line('	e.preventDefault();');
  dbms_output.put_line('	if(selRowId < -1)return;');
  dbms_output.put_line(' ');	
  
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
	dbms_output.put_line('	var str' || replace(initcap(v_column_name),'_', '') || ' = grid.getValue(selRowId,"' || lower(v_column_name) || '",false);');
  END LOOP;
  CLOSE c_2;
  
  dbms_output.put_line(' ');	
  dbms_output.put_line('	if ( false ');

  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
	dbms_output.put_line('		|| ( str' || replace(initcap(v_column_name),'_', '') || ' == null || str' || replace(initcap(v_column_name),'_', '') || ' == "" )');
  END LOOP;
  CLOSE c_2;  
  
  dbms_output.put_line('	){');
  dbms_output.put_line('		grid.removeRow(selRowId);');
  dbms_output.put_line('		selRowId = -1;');
  dbms_output.put_line('		clearControl();');
  dbms_output.put_line('		return;');
  dbms_output.put_line('	}');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	var vConf = "정보를 삭제 하시겠습니까?";');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	swal({');
  dbms_output.put_line('		title : "삭제",');
  dbms_output.put_line('		text : vConf,');
  dbms_output.put_line('		type : "warning",');
  dbms_output.put_line('		showCancelButton : true,');
  dbms_output.put_line('		confirmButtonColor : "#DD6B55",');
  dbms_output.put_line('		confirmButtonText : "삭제",');
  dbms_output.put_line('		cancelButtonText : "취소",');		        
  dbms_output.put_line('		closeOnConfirm : false');
  dbms_output.put_line('		},');
  dbms_output.put_line('		function () {');
  dbms_output.put_line('			deleteAction(strLmsNo,strLmsRo);');
  dbms_output.put_line('		});');
  dbms_output.put_line('	}');  
  dbms_output.put_line(' ');  
  
  dbms_output.put_line('///////////// init');  
  dbms_output.put_line(' ');  

---------------------------------------------------------------------------
-- function  initSet()  
---------------------------------------------------------------------------   

  dbms_output.put_line('function initSet() {');
  dbms_output.put_line('	//설정된 버튼권한 설정');
  dbms_output.put_line('	setDefaultButton();');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');

---------------------------------------------------------------------------
-- function  initBind()  
---------------------------------------------------------------------------

  dbms_output.put_line('function initBind() {');
  dbms_output.put_line(' ');
  dbms_output.put_line('	// 조회 버튼 클릭 이벤트 등록');
  dbms_output.put_line('	$("#view").bind("click", btnSearch_clickEvent);');
  dbms_output.put_line('	// 추가 버튼 클릭 이벤트 등록');
  dbms_output.put_line('	$("#add").bind("click", btnAdd_clickEvent);');
  dbms_output.put_line('	// 삭제 버튼 클릭 이벤트 등록');
  dbms_output.put_line('	$("#delete").bind("click", btnDel_clickEvent);');
  dbms_output.put_line('	// 저장 버튼 클릭 이벤트 등록');
  dbms_output.put_line('	$("#save").bind("click", btnSave_clickEvent);');
  dbms_output.put_line(' ');	
  dbms_output.put_line('	//control binding');
  dbms_output.put_line(' ');	
  
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name, v_data_length;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('	$("#' || lower(v_column_name) || '").bind("change", ' || lower(v_column_name) || '_changeEvent);');
  END LOOP;
  CLOSE c_2;
  	
  dbms_output.put_line(' ');	
  dbms_output.put_line('}');
  dbms_output.put_line(' ');
  
---------------------------------------------------------------------------
-- function  initData()  
---------------------------------------------------------------------------   

  dbms_output.put_line('function initData() {');
  dbms_output.put_line('	btnSearchClicked();');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');  

---------------------------------------------------------------------------
-- function  initGrid()  
--------------------------------------------------------------------------- 

  dbms_output.put_line('function initGrid() {');
  dbms_output.put_line('	grid = new tui.Grid({');
  dbms_output.put_line('		el: $("#grid"),');
  dbms_output.put_line('		scrollX: true,');
  dbms_output.put_line('		scrollY: true,');
  dbms_output.put_line('		width : "auto",');
  dbms_output.put_line('		bodyHeight: 500,');
  dbms_output.put_line('		columns: [');

  OPEN cc_1;
  LOOP
    FETCH cc_1 INTO v_column_name, v_comments;
    EXIT WHEN cc_1%notfound;
    dbms_output.put_line('			{title: "' || v_comments || '", 		name: "' || lower(v_column_name) || '",	 width : 150,	align: "center",	hidden: false, sortable:true},');
  END LOOP;
  CLOSE cc_1;

  OPEN cc_3;
  LOOP
    FETCH cc_3 INTO v_column_name, v_comments;
    EXIT WHEN cc_3%notfound;
    dbms_output.put_line('			{title: "' || v_comments || '", 		name: "' || lower(v_column_name) || '",	 width : 150,	align: "center",	hidden: false, sortable:true},');
  END LOOP;
  CLOSE cc_3;

  dbms_output.put_line('		]');
  dbms_output.put_line('	});');
  dbms_output.put_line(' ');			
  dbms_output.put_line('	grid.on("click", function(ev) {');
  dbms_output.put_line(' ');		
  dbms_output.put_line('	});');
  dbms_output.put_line(' ');			
  dbms_output.put_line('	grid.on("focusChange", function(ev) {');
  dbms_output.put_line('		if(ev.rowKey == undefined)');
  dbms_output.put_line('			return;');
  dbms_output.put_line('		if(selRowId == ev.rowKey)');
  dbms_output.put_line('			return;');		
  dbms_output.put_line('		selRowId = ev.rowKey;');		
  dbms_output.put_line('		bindControlByGrid(ev.rowKey);');
  dbms_output.put_line('	});');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');
  
  dbms_output.put_line('function initControls(){');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');
  
  dbms_output.put_line('//// init Page');
  dbms_output.put_line('$(document).ready(function() {');
  dbms_output.put_line('	initSet();');
  dbms_output.put_line('	initBind();	     //이벤트등록');
  dbms_output.put_line('	initGrid();	     //그리드 초기화');
  dbms_output.put_line('	initControls();  //date picker'); 
  dbms_output.put_line('	//initData();');
  
  dbms_output.put_line('	initTest();	// 테스트 용도');  
  dbms_output.put_line('});');    

END makejsbytable;
