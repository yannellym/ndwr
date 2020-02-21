use ndwr;
CREATE TABLE `ndwr`.`ndwr_all_patients` (
  `patientid` INT NOT NULL,
  `PatientPK` INT NOT NULL,
  `SiteCode` INT NOT NULL,
  `facilityname` VARCHAR(100) NULL,
  `Gender` VARCHAR(10) NULL,
  `DOB` DATETIME NULL,
  `RegistrationDate` DATETIME NOT NULL,
  `RegistrationAtCCC` DATETIME NOT NULL,
  `RegistrationAtPMTCT` DATETIME NULL,
  `RegistrationAtTBClinic` DATETIME NULL,
  `PatientSource` VARCHAR(100) NULL,
  `Region` VARCHAR(100) NULL,
  `District` VARCHAR(100) NULL,
  `Village` VARCHAR(100) NULL,
  `ContactRelation` VARCHAR(250) NULL,
  `LastVisit` DATETIME NULL,
  `MaritalStatus` VARCHAR(100) NULL,
  `EducationLevel` VARCHAR(50) NULL,
  `DateConfirmedHIVPositive` DATETIME NULL,
  `PreviousARTExposure` VARCHAR(50) NULL,
  `PreviousARTStartDate` DATETIME NULL,
  `Emr` VARCHAR(50) NULL,
  `project` VARCHAR(50) NULL,
  `FacilityID` INT NULL,
  `StatusAtCCC` VARCHAR(100) NULL,
  `StatusAtPMTCT` VARCHAR(100) NULL,
  `StatusAtTBClinic` VARCHAR(100) NULL,
  `SatelliteName` VARCHAR(100) NULL,
  `arv_first_regimen_start_date` DATE NULL,
  `rtc_date` DATE NULL,
  `arv_first_regimen` VARCHAR(200) NULL,
  `arv_start_date` DATE NULL,
  `cur_arv_meds` VARCHAR(200) NULL,
  `cur_arv_line_strict` VARCHAR(250) NULL,
  `Inschool` VARCHAR(100) NULL,
  `KeyPopulationType` VARCHAR(100) NULL,
  `Orphan` VARCHAR(100) NULL,
  `PatientResidentCounty` VARCHAR(100) NULL,
  `PatientResidentLocation` VARCHAR(100) NULL,
  `PatientResidentSubCounty` VARCHAR(100) NULL,
  `PatientResidentSubLocation` VARCHAR(100) NULL,
  `PatientResidentVillage` VARCHAR(100) NULL,
  `PatientResidentWard` VARCHAR(100) NULL,
  `PatientType` VARCHAR(100) NULL,
  `PopulationType` VARCHAR(100) NULL,
  `TransferInDate` DATETIME NULL);
