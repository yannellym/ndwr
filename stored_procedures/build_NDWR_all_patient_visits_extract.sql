DELIMITER $$
CREATE  PROCEDURE `build_NDWR_all_patient_visits_extract`(IN query_type varchar(50) , IN queue_number int, IN queue_size int, IN cycle_size int, IN log BOOLEAN)
BEGIN

					set @primary_table := "ndwr_all_patient_visits_extract";
                    set @total_rows_written = 0;
					set @start = now();
					set @table_version = "ndwr_all_patient_visits_extract_v1.1";
                    set @query_type = query_type;

CREATE TABLE IF NOT EXISTS `ndwr`.`ndwr_all_patient_visits_extract` (
  `PatientPK` INT NOT NULL,
  `SiteCode` INT NULL,
  `PatientID` INT NOT NULL,
  `FacilityID` INT NULL,
  `Emr` VARCHAR(50) NULL,
  `Project` VARCHAR(50) NULL,
  `FacilityName` VARCHAR(100) NULL,
  `VisitID` INT NULL,
  `VisitDate` DATETIME NULL,
  `Service` VARCHAR(50) NULL,
  `VisitType` VARCHAR(50) NULL,
  `VisitBy` VARCHAR(50) NULL,
  `Height` INT NULL,
  `Weight` INT NULL,
  `Temp` INT NULL,
  `PulseRate` INT NULL,
  `RespiratoryRate` INT NULL,
  `OxygenSaturation` INT NULL,
  `MUAC` INT NULL,
  `BP` VARCHAR(50) NULL,
  `NutritionStatus` VARCHAR(10) NULL,
  `WHOStage` INT NULL,
  `WABStage` INT NULL,
  `EverHadMenses` VARCHAR(10) NULL,
  `LMP` DATETIME NULL,
  `Pregnant` VARCHAR(20) NULL,
  `Breastfeeding` VARCHAR(20) NULL,
  `EDD` DATETIME NULL,
  `Menopausal` tinyint,
  `FamilyPlanningMethod` VARCHAR(200),
  `NoFPReason` VARCHAR(200) NULL,
  `OI` VARCHAR(200) NULL,
  `OIDate` DATETIME NULL,
  `SystemExamination` VARCHAR(20) NULL,
  `Adherence` VARCHAR(200) NULL,
  `AdherenceCategory` VARCHAR(200) NULL,
  `CurrentRegimen`VARCHAR(200) NULL,
  `PwP` VARCHAR(200) NULL,
  `StabilityAssessment` VARCHAR(50) NULL,
  `HCWConcern` VARCHAR(500) NULL,
  `NextAppointmentDate` DATETIME NULL,
  `TCAReason` VARCHAR(50) NULL,
  `DifferentiatedCare` VARCHAR(50) NULL,
  `SubstitutionFirstlineRegimenDate` DATETIME NULL,
  `SubstitutionFirstlineRegimenReason` VARCHAR(500) NULL,
  `SubstitutionSecondlineRegimenDate` DATETIME NULL,
  `SubstitutionSecondlineRegimenReason` VARCHAR(500) NULL,
  `SecondlineRegimenChangeDate` DATETIME NULL,
  `SecondlineRegimenChangeReason` VARCHAR(500) NULL,
  `ProphylaxisUsed` VARCHAR(100) NULL,
  `CTXAdherence` VARCHAR(100) NULL,
  `ClinicalNotes` VARCHAR(500) NULL
  `DateCreated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   INDEX visit_patient_id (PatientID),
   INDEX visit_patient_pk (PatientPK),
   INDEX visit_facility_id (FacilityID),
   INDEX visit_site_code (SiteCode),
   INDEX visit_visit_date (VisitDate),
   INDEX visit_date_created (DateCreated),
   INDEX visit_patient_visit (PatientID,VisitDate),
   INDEX visit_patient_facility (PatientID,FacilityID)
  );

                    set @last_date_created = (select max(DateCreated) from ndwr.ndwr_all_patient_visits_extract);

                    if(@query_type="build") then

							              select 'BUILDING..........................................';
                            set @write_table = concat("ndwr_all_patient_visits_extract_temp_",queue_number);
                            set @queue_table = concat("ndwr_all_patient_visits_extract_build_queue_",queue_number);                    												

										  SET @dyn_sql=CONCAT('create table if not exists ',@write_table,' like ',@primary_table);
							              PREPARE s1 from @dyn_sql; 
							              EXECUTE s1; 
							              DEALLOCATE PREPARE s1;  


							              SET @dyn_sql=CONCAT('Create table if not exists ',@queue_table,' (select * from ndwr_all_patient_visits_extract_build_queue limit ', queue_size, ');'); 
							              PREPARE s1 from @dyn_sql; 
							              EXECUTE s1; 
							              DEALLOCATE PREPARE s1;  

							              SET @dyn_sql=CONCAT('delete t1 from ndwr_all_patient_visits_extract_build_queue t1 join ',@queue_table, ' t2 using (person_id);'); 
                            PREPARE s1 from @dyn_sql; 
							              EXECUTE s1; 
							              DEALLOCATE PREPARE s1;  
                                          
					SET @person_ids_count = 0;
                    SET @dyn_sql=CONCAT('select count(*) into @person_ids_count from ',@queue_table); 
                    PREPARE s1 from @dyn_sql; 
                    EXECUTE s1; 
                    DEALLOCATE PREPARE s1;

                   SELECT @person_ids_count AS 'num patients to build';

				  end if;
          if (@query_type="sync") then
                            select 'SYNCING..........................................';
                            set @write_table = concat("ndwr_all_patient_visits_extract_temp_",queue_number);
							SET @dyn_sql=CONCAT('create table if not exists ',@write_table,' like ',@primary_table);
							PREPARE s1 from @dyn_sql; 
							EXECUTE s1; 
							DEALLOCATE PREPARE s1;  
                                          
                            set @queue_table = "ndwr_all_patient_visits_extract_sync_queue";
                            CREATE TABLE IF NOT EXISTS ndwr.ndwr_all_patient_visits_extract_sync_queue (
                                person_id INT(6) UNSIGNED,
                                INDEX visits_sync_person_id (person_id)
                            );                            
                            
                            set @last_update = null;
                            SELECT 
                                MAX(date_updated)
                            INTO @last_update FROM
                                ndwr.flat_log
                            WHERE
                                table_name = @table_version;

                            replace into ndwr.ndwr_all_patient_visits_extract_sync_queue
                             (select distinct person_id from etl.flat_hiv_summary_v15b where date_created >= @last_update);
                             
                             SET @person_ids_count = 0;
							 SET @dyn_sql=CONCAT('select count(*) into @person_ids_count from ',@queue_table); 
							 PREPARE s1 from @dyn_sql; 
							 EXECUTE s1; 
							 DEALLOCATE PREPARE s1;

							 SELECT @person_ids_count AS 'num patients to sync';

            end if;

                    set @total_time=0;
                    set @cycle_number = 0;

                    while @person_ids_count > 0 do

                        	set @loop_start_time = now();
							drop temporary table if exists ndwr_all_patient_visits_extract_build_queue__0;

                          SET @dyn_sql=CONCAT('create temporary table if not exists ndwr_all_patient_visits_extract_build_queue__0 (person_id int primary key) (select * from ',@queue_table,' limit ',cycle_size,');'); 
						              PREPARE s1 from @dyn_sql; 
						              EXECUTE s1; 
						              DEALLOCATE PREPARE s1;
                                      
						SELECT CONCAT('Deleting data from ', @primary_table);
                                      
						 SET @dyn_sql=CONCAT('delete t1 from ',@primary_table,' t1 join ndwr_all_patient_visits_extract_build_queue__0 t2 on (t1.PatientPK = t2.person_id);'); 
						 PREPARE s1 from @dyn_sql; 
                          EXECUTE s1; 
					                DEALLOCATE PREPARE s1; 
                                      
						  
                drop temporary table if exists ndwr_all_patient_visits_extract_interim;

                SELECT CONCAT('Creating and populating interim table ..');
                          
                create temporary table ndwr_all_patient_visits_extract_interim (
                       SELECT distinct
						   e.person_id AS PatientPK,
                           mfl.mfl_code as SiteCode,
                           e.person_id AS PatientID,
   						   mfl.mfl_code as FacilityID,
                           'AMRS' AS Emr,
						   'Ampath Plus' AS Project,
                           mfl.Facility AS FacilityName,
                           e.encounter_id AS VisitID,
                           e.encounter_datetime AS VisitDate,
                           'ART' as Service,
                           case
                             when e.scheduled_visit = '1246' then 'SCHEDULED VISIT'
                             when e.scheduled_visit = '1838' then 'UNSCHEDULED VISIT LATE'
                             when e.scheduled_visit = '1837' then 'UNSCHEDULED VISIT EARLY'
                             when e.scheduled_visit = '8914' then 'UNSCHEDULED OUTPATIENT VISIT'
                             when e.scheduled_visit = '2345' then 'FOLLOW-UP'
                             when e.scheduled_visit = '7850' then 'INITIAL VISIT'
                             else 'Unknownknown'
                           end as VisitType,
                           null as VisitBy,
                           v.Height AS 'Height',
                           v.Weight AS 'Weight',
                           null as 'Temp',
                           null as 'PulseRate',
                           null as 'Respiratory Rate',
                           null as 'Oxygen Saturation',
                           null as 'MUAC',
                           concat(v.systolic_bp,'/',v.diastolic_bp) AS 'BP',
                           null as 'NutritionStatus',
                           e.cur_who_stage AS 'WHOStage',
                           null  AS 'WABStage',
                           null as 'EverHadMenses',
                           if(e.edd,date_add(e.edd, interval -280 day),null) AS 'LMP',
                           if(e.edd,'Yes',null) AS 'Pregnant',
                           null as 'Breastfeeding',
                           e.edd as 'EDD',
                           null as 'Menopausal',
                           IF(e.contraceptive_method,e.contraceptive_method,null) AS 'FamilyPlanningMethod',
                           null as 'NoFPReason',
                           case
	                         when o.obs regexp "!!6042=" then replace(replace((substring_index(substring(o.obs,locate("!!6042=",o.obs)),'##',ROUND ((LENGTH(o.obs) - LENGTH( REPLACE ( o.obs, "!!6042=", "") ) ) / LENGTH("!!6042=") ))),"!!6042=",""),"!!","")
	                         else null
	                       end as 'OI',
	                       case
	                         when o.obs regexp "!!6042=" then o.encounter_datetime
	                         else null
	                       end as 'OIDate',
                           null as 'SystemExamination',
                           e.cur_arv_adherence AS 'Adherence',
                           e.cur_arv_adherence AS 'AdherenceCategory',
                           REPLACE(etl.get_arv_names(cur_arv_meds), "##", "+") as 'CurrentRegimen',
                           e.contraceptive_method AS PwP,
                           null as StabilityAssessment,
                           null as HCWConcern,
                           case
                             when e.rtc_date IS NOT NULL then e.rtc_date
                             ELSE DATE_ADD(e.encounter_datetime, INTERVAL 21 DAY)
                           end as NextAppointmentDate,
                           null as 'TCAReason',
                           null as 'DifferentiatedCare',
                           null as 'SubstitutionFirstlineRegimenDate',
                           null as 'SubstitutionFirstlineRegimenReason',
                           null as 'SubstitutionSecondlineRegimenDate',
                           null as 'SubstitutionSecondlineRegimenReason',
						   null as 'SecondlineRegimenChangeDate',
						   null as 'SecondlineRegimenChangeReason',
                           null as 'ProphylaxisUsed',
                           null as 'CTXAdherence',
                           null as 'ClinicalNotes',
                           null as 'DateCreated'
					
                           FROM etl.flat_hiv_summary_v15b e 
                           inner join ndwr_all_patient_visits_extract_build_queue__0 t3 on (t3.person_id = e.person_id)
                           left join ndwr.mfl_codes mfl on (mfl.location_id = e.location_id)
                           LEFT JOIN etl.flat_vitals v ON (v.person_id = e.person_id AND v.encounter_datetime = e.encounter_datetime)
                           LEFT JOIN etl.flat_obs o on (o.encounter_datetime=e.encounter_datetime and e.person_id=o.person_id)
                       ); 
                          
						 SELECT CONCAT('Created interim table ..');


SELECT 
    COUNT(*)
INTO @new_encounter_rows FROM
    ndwr_all_patient_visits_extract_interim;
SELECT @new_encounter_rows;                    
                          set @total_rows_written = @total_rows_written + @new_encounter_rows;
SELECT @total_rows_written;

                          SET @dyn_sql=CONCAT('replace into ',@write_table,'(select * from ndwr_all_patient_visits_extract_interim)');

                          PREPARE s1 from @dyn_sql; 
                          EXECUTE s1; 
                          DEALLOCATE PREPARE s1;

                          SET @dyn_sql=CONCAT('delete t1 from ',@queue_table,' t1 join ndwr_all_patient_visits_extract_build_queue__0 t2 using (person_id);'); 
					                PREPARE s1 from @dyn_sql; 
                          EXECUTE s1; 
					                DEALLOCATE PREPARE s1;  
                        

						 SET @dyn_sql=CONCAT('select count(*) into @person_ids_count from ',@queue_table,';'); 
                         PREPARE s1 from @dyn_sql; 
                         EXECUTE s1; 
                         DEALLOCATE PREPARE s1;
                         
                         set @cycle_length = timestampdiff(second,@loop_start_time,now());
                         set @total_time = @total_time + @cycle_length;
                         set @cycle_number = @cycle_number + 1;
                         set @remaining_time = ceil((@total_time / @cycle_number) * ceil(@person_ids_count / cycle_size) / 60);
                         
SELECT 
    @person_ids_count AS 'persons remaining',
    @cycle_length AS 'Cycle time (s)',
    CEIL(@person_ids_count / cycle_size) AS remaining_cycles,
    @remaining_time AS 'Est time remaining (min)';


                    end while;

                         SET @dyn_sql=CONCAT('drop table ',@queue_table,';');
                         PREPARE s1 from @dyn_sql;
                         EXECUTE s1;
                         DEALLOCATE PREPARE s1;  

                         SET @total_rows_to_write=0;
                         SET @dyn_sql=CONCAT("Select count(*) into @total_rows_to_write from ",@write_table);
                         PREPARE s1 from @dyn_sql; 
                         EXECUTE s1; 
                         DEALLOCATE PREPARE s1;

                         set @start_write = now();
                         
SELECT 
    CONCAT(@start_write,
            ' : Writing ',
            @total_rows_to_write,
            ' to ',
            @primary_table);

                        SET @dyn_sql=CONCAT('replace into ', @primary_table,'(select * from ',@write_table,');');
                        PREPARE s1 from @dyn_sql; 
                        EXECUTE s1;
                        DEALLOCATE PREPARE s1;

SELECT 
    CONCAT(@finish_write,
            ' : Completed writing rows. Time to write to primary table: ',
            @time_to_write,
            ' seconds ');
            
                        SET @dyn_sql=CONCAT('drop table ',@write_table,';');
                        PREPARE s1 from @dyn_sql; 
                        EXECUTE s1; 
                        DEALLOCATE PREPARE s1;
                        
                        
                        set @ave_cycle_length = ceil(@total_time/@cycle_number);
SELECT 
    CONCAT('Average Cycle Length: ',
            @ave_cycle_length,
            'second(s)');
                        set @end = now();
                        
insert into ndwr.flat_log values (@start,@last_date_created,@table_version,timestampdiff(second,@start,@end));
                        
SELECT 
    CONCAT(@table_version,
            ' : Time to complete: ',
            TIMESTAMPDIFF(MINUTE, @start, @end),
            ' minutes');


END$$
DELIMITER ;
