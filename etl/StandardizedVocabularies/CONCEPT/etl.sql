
---- should be 0 for that code,
---- and units push inside source_concept_id
ALTER TABLE omop.concept DISABLE TRIGGER ALL;
DELETE FROM omop.concept WHERE concept_id >= 500000000;
ALTER TABLE omop.concept ENABLE TRIGGER ALL;

--MIMIC-OMOP
INSERT INTO omop.concept (
concept_id,concept_name,domain_id,vocabulary_id,concept_class_id,concept_code,valid_start_date,valid_end_date
) VALUES 
  (2000000000,'Stroke Volume Variation','Measurement','MIMIC Generated','Clinical Observation','','1979-01-01','2099-01-01')
, (2000000001,'L/min/m2','Unit','MIMIC Generated','','','1979-01-01','2099-01-01')
, (2000000002,'dynes.sec.cm-5/m2','Unit','MIMIC Generated','','','1979-01-01','2099-01-01')
, (2000000003,'Output Event','Type Concept','MIMIC Generated','Meas Type','','1979-01-01','2099-01-01')
;

--ITEMS
INSERT INTO omop.concept (
concept_id,concept_name,domain_id,vocabulary_id,concept_class_id,concept_code,valid_start_date,valid_end_date
) 
SELECT 
  mimic_id as concept_id
, coalesce(label, 'UNKNOWN') as concept_name
, 'Measurement'::text as domain_id
, 'MIMIC Generated' as vocabulary_id
, '' as concept_class_id
, itemid as concept_code
, '1979-01-01' as valid_start_date
, '2099-01-01' as valid_end_date
FROM d_items;

--LABS
INSERT INTO omop.concept (
concept_id,concept_name,domain_id,vocabulary_id,concept_class_id,concept_code,valid_start_date,valid_end_date
) 
SELECT 
  mimic_id as concept_id
, coalesce(label || '[' || fluid || '][' || category || ']', 'UNKNOWN') as concept_name
, 'Measurement'::text as domain_id
, 'MIMIC Generated' as vocabulary_id
, '' as concept_class_id
, itemid as concept_code
, '1979-01-01' as valid_start_date
, '2099-01-01' as valid_end_date
FROM d_labitems;


-- DRUGS
-- Generates LOCAL concepts for mimic drugs
INSERT INTO omop.concept (
concept_id,concept_name,domain_id,vocabulary_id,concept_class_id,concept_code,valid_start_date,valid_end_date
) 
SELECT 
distinct on (drug, prod_strength)
  nextval('mimic.mimic_id_seq') as concept_id
, trim(drug || ' ' || prod_strength) as concept_name
, 'Drug'::text as domain_id
, 'MIMIC Generated' as vocabulary_id
, drug_type as concept_class_id
, coalesce(ndc,'') as concept_code
, '1979-01-01' as valid_start_date
, '2099-01-01' as valid_end_date
FROM prescriptions;