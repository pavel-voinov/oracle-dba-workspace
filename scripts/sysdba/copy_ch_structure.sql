set serveroutput on size unlimited echo on timing on

spool copy_ch_structure.log

ALTER SESSION ENABLE PARALLEL DML;

DECLARE
  l_sql_stmt VARCHAR2(1000);
  l_try NUMBER;
  l_status NUMBER;
BEGIN
  -- Create the TASK
  dbms_parallel_execute.create_task(task_name => 'copy_ch_structure', comment => 'Copy CI_PUBLIC_STAGING.CH_STRUCTURE into CI_PUBLIC.CH_STRUCTURE');
 
  -- Chunk the table by STRUCTURE_ID
  dbms_parallel_execute.create_chunks_by_number_col(task_name => 'copy_ch_structure',
                                        table_owner => 'CI_PUBLIC_STAGING',
                                        table_name => 'CH_STRUCTURE',
                                        table_column => 'STRUCTURE_ID',
                                        chunk_size => 50000);
 
  -- Execute the DML in parallel
  l_sql_stmt := 'INSERT INTO CI_PUBLIC.CH_STRUCTURE (structure_id, ctab, molfile, chime, mol_weight, mol_formula, inchi, inchikey, smiles, systematic_name, added_date, update_date, display_image, thumbnail_image, is_v3000, is_chiral, is_combination, count_fragments, do_scn)
SELECT structure_id, ctab, molfile, chime, mol_weight, mol_formula, inchi, inchikey, smiles, systematic_name, added_date, update_date, display_image, thumbnail_image, is_v3000, is_chiral, is_combination, count_fragments, do_scn
FROM CI_PUBLIC_STAGING.CH_STRUCTURE WHERE structure_id BETWEEN :start_id AND :end_id';
  dbms_parallel_execute.run_task(task_name => 'copy_ch_structure', sql_stmt => l_sql_stmt, language_flag => DBMS_SQL.NATIVE, parallel_level => 50);
 
  -- If there is an error, RESUME it for at most 2 times.
  l_try := 0;
  l_status := dbms_parallel_execute.task_status(task_name => 'copy_ch_structure');

  WHILE(l_try < 2 and l_status != dbms_parallel_execute.finished) 
  LOOP
    l_try := l_try + 1;
    dbms_parallel_execute.resume_task(task_name => 'copy_ch_structure');
    l_status := dbms_parallel_execute.task_status(task_name => 'copy_ch_structure');
  END LOOP;
 
  -- Done with processing and drop the task
  dbms_parallel_execute.drop_task(task_name => 'copy_ch_structure');
END;
/

spool off
