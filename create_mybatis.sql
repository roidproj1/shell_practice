create or replace PROCEDURE makexmlbytable (
  p_table_name IN   VARCHAR2
) IS

  v_column_name   VARCHAR2(50);
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

--all column

  CURSOR c_2 IS
  SELECT
    column_name
  FROM
    user_tab_columns
  WHERE
    table_name = p_table_name
  ORDER BY
    column_id;

--all column exception pk column

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

BEGIN
  dbms_output.enable('10000000000');
---------------------------------------------------------------------------
--   DBMS_OUTPUT.PUT_LINE( 'table name:' || p_table_name );
---------------------------------------------------------------------------
  dbms_output.put_line(' <sql id="sqlWhere">');
  dbms_output.put_line('     WHERE  1 = 1');
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    dbms_output.put_line('        <if test="'
                         || lower(v_column_name)
                         || ' != null">');
    dbms_output.put_line('            AND  t1.'
                         || lower(v_column_name)
                         || ' = #{'
                         || lower(v_column_name)
                         || '}');

    dbms_output.put_line('        </if>');
  END LOOP;

  CLOSE c_1;
  dbms_output.put_line(' </sql>');
  dbms_output.put_line(' ');
  
  ---------------------------------------------------------------------------
--   DBMS_OUTPUT.PUT_LINE( 'table name:' || p_table_name );
---------------------------------------------------------------------------
  dbms_output.put_line(' <sql id="sqlWhere2">');
  dbms_output.put_line('     WHERE  1 = 1');
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('        <if test="'
                         || lower(v_column_name)
                         || ' != null">');
    dbms_output.put_line('            AND  t1.'
                         || lower(v_column_name)
                         || ' = #{'
                         || lower(v_column_name)
                         || '}');

    dbms_output.put_line('        </if>');
  END LOOP;
  CLOSE c_2;
  dbms_output.put_line(' </sql>');
  dbms_output.put_line(' ');
  
  dbms_output.put_line(' <!-- 데이터 목록 맵. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.selectMap'))) || ' -->');
  dbms_output.put_line(' <resultMap id="selectMap" type="map">');
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name;
    EXIT WHEN c_2%notfound;
    dbms_output.put_line('        <result property="'
                         || lower(v_column_name)
                         || '"    column="'
                         || upper(v_column_name)
                         || '"    />');

  END LOOP;

  CLOSE c_2;
  dbms_output.put_line(' </resultMap>');
  dbms_output.put_line(' ');
  dbms_output.put_line(' <!-- 데이터 목록을 조회한다. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.selectList'))) || ' -->');  
  dbms_output.put_line(' <select id="selectList" parameterType="map" resultMap="selectMap">');
  dbms_output.put_line('     SELECT');
  v_cnt := 0;
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name;
    EXIT WHEN c_2%notfound;
    IF v_cnt = 0 THEN
      dbms_output.put_line('              t1.' || lower(v_column_name));
    ELSE
      dbms_output.put_line('            , t1.' || lower(v_column_name));
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_2;
  dbms_output.put_line('     FROM  '
                       || p_table_name
                       || '  t1');
  dbms_output.put_line('     <include refid="sqlWhere"/>');
  dbms_output.put_line(' </select>');
  dbms_output.put_line(' ');
  dbms_output.put_line(' <!-- 데이터 레코드 수를 조회한다. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.selectListCount'))) || ' -->');    
  dbms_output.put_line(' <select id="selectListCount" parameterType="map" resultType="map">');
  dbms_output.put_line('     SELECT  COUNT(1)  rows_tot');
  dbms_output.put_line('     FROM  '
                       || p_table_name
                       || '  t1');
  dbms_output.put_line('     <include refid="sqlWhere"/>');
  dbms_output.put_line(' </select>');
  dbms_output.put_line(' ');
  dbms_output.put_line(' <!-- PK값으로 데이터를[을] 조회한다. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.select'))) || ' -->'); 
  dbms_output.put_line(' <select id="select" parameterType="map" resultMap="selectMap">');
  dbms_output.put_line('     SELECT');
  v_cnt := 0;
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name;
    EXIT WHEN c_2%notfound;
    IF v_cnt = 0 THEN
      dbms_output.put_line('              t1.' || lower(v_column_name));
    ELSE
      dbms_output.put_line('            , t1.' || lower(v_column_name));
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_2;
  dbms_output.put_line('     FROM  '
                       || p_table_name
                       || '  t1');
  v_cnt := 0;
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    IF v_cnt = 0 THEN
      dbms_output.put_line('    WHERE  t1.'
                           || lower(v_column_name)
                           || ' = #{'
                           || lower(v_column_name)
                           || '}');
    ELSE
      dbms_output.put_line('        AND  t1.'
                           || lower(v_column_name)
                           || ' = #{'
                           || lower(v_column_name)
                           || '}');
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_1;
  dbms_output.put_line(' </select>');
  dbms_output.put_line(' ');
  dbms_output.put_line(' <!-- 데이터를[을] 입력한다. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.insert'))) || ' -->');   
  dbms_output.put_line(' <insert id="insert" parameterType="map">');
  dbms_output.put_line('     INSERT  INTO '
                       || p_table_name
                       || ' (');
  v_cnt := 0;
  OPEN c_2;
  LOOP
    FETCH c_2 INTO v_column_name;
    EXIT WHEN c_2%notfound;
    IF lower(v_column_name) != 'upd_dt' AND lower(v_column_name) != 'inp_dt' THEN
      IF v_cnt = 0 THEN
        dbms_output.put_line('              ' || lower(v_column_name));
      ELSE
        dbms_output.put_line('            , ' || lower(v_column_name));
      END IF;
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_2;
  dbms_output.put_line('     ) VALUES (');
  v_cnt := 0;
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    IF v_cnt = 0 THEN
      dbms_output.put_line('              #{'
                           || lower(v_column_name)
                           || '}');
    ELSE
      dbms_output.put_line('            , #{'
                           || lower(v_column_name)
                           || '}');
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_1;
  OPEN c_3;
  LOOP
    FETCH c_3 INTO v_column_name;
    EXIT WHEN c_3%notfound;
    IF lower(v_column_name) != 'upd_dt' AND lower(v_column_name) != 'inp_dt' THEN
      IF lower(v_column_name) = 'inp_id' OR lower(v_column_name) = 'upd_id' THEN
        dbms_output.put_line('        <if test="login_id != null">');
        dbms_output.put_line('            , #{login_id}');
        dbms_output.put_line('        </if>');
        dbms_output.put_line('        <if test="login_id == null">');
        dbms_output.put_line('            , null');
        dbms_output.put_line('        </if>');
      ELSE
        dbms_output.put_line('        <if test="'
                             || lower(v_column_name)
                             || ' != null">');
        dbms_output.put_line('            , #{'
                             || lower(v_column_name)
                             || '}');
        dbms_output.put_line('        </if>');
        dbms_output.put_line('        <if test="'
                             || lower(v_column_name)
                             || ' == null">');
        dbms_output.put_line('            , null');
        dbms_output.put_line('        </if>');
      END IF;
    END IF;

  END LOOP;

  CLOSE c_3;
  dbms_output.put_line('     )');
  dbms_output.put_line(' </insert>');
  dbms_output.put_line(' ');
  dbms_output.put_line(' <!-- 데이터를[을] 수정한다. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.update'))) || ' -->');     
  dbms_output.put_line(' <update id="update" parameterType="map">');
  dbms_output.put_line('     UPDATE  ' || p_table_name);
  dbms_output.put_line('     set');
  v_cnt := 0;
  OPEN c_3;
  LOOP
    FETCH c_3 INTO v_column_name;
    EXIT WHEN c_3%notfound;
    IF lower(v_column_name) != 'upd_dt' AND lower(v_column_name) != 'inp_dt' AND lower(v_column_name) != 'upd_id' AND lower(v_column_name
    ) != 'inp_id' THEN
      IF v_cnt = 0 THEN
        dbms_output.put_line('        <if test="'
                             || lower(v_column_name)
                             || ' != null">');
        dbms_output.put_line('            '
                             || lower(v_column_name)
                             || ' = #{'
                             || lower(v_column_name)
                             || '}');

        dbms_output.put_line('        </if>');
      ELSE
        dbms_output.put_line('        <if test="'
                             || lower(v_column_name)
                             || ' != null">');
        dbms_output.put_line('            ,'
                             || lower(v_column_name)
                             || ' = #{'
                             || lower(v_column_name)
                             || '}');

        dbms_output.put_line('        </if>');
      END IF;
    ELSIF lower(v_column_name) = 'upd_dt' THEN
      dbms_output.put_line('            ,upd_dt = sysdate');
    ELSIF lower(v_column_name) = 'upd_id' THEN
      dbms_output.put_line('        <if test="login_id != null">');
      dbms_output.put_line('            ,upd_id = #{login_id}');
      dbms_output.put_line('        </if>');
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_3;
  v_cnt := 0;
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    IF v_cnt = 0 THEN
      dbms_output.put_line('      WHERE  '
                           || lower(v_column_name)
                           || ' = #{'
                           || lower(v_column_name)
                           || '}');
    ELSE
      dbms_output.put_line('        AND  '
                           || lower(v_column_name)
                           || ' = #{'
                           || lower(v_column_name)
                           || '}');
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_1;
  dbms_output.put_line(' </update>');
  dbms_output.put_line(' ');
  dbms_output.put_line(' <!-- 데이터를[을] 삭제한다. -->');
  dbms_output.put_line(' <!-- ' || utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(upper(p_table_name) || '.delete'))) || ' -->');       
  dbms_output.put_line(' <delete id="delete" parameterType="map">');
  dbms_output.put_line('     DELETE  FROM ' || p_table_name);
  v_cnt := 0;
  OPEN c_1;
  LOOP
    FETCH c_1 INTO v_column_name;
    EXIT WHEN c_1%notfound;
    IF v_cnt = 0 THEN
      dbms_output.put_line('      WHERE  '
                           || lower(v_column_name)
                           || ' = #{'
                           || lower(v_column_name)
                           || '}');
    ELSE
      dbms_output.put_line('        AND  '
                           || lower(v_column_name)
                           || ' = #{'
                           || lower(v_column_name)
                           || '}');
    END IF;

    v_cnt := v_cnt + 1;
  END LOOP;

  CLOSE c_1;
  dbms_output.put_line(' </delete>');
END makexmlbytable;
