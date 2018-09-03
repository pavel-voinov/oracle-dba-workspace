set serveroutput on size unlimited echo on 

GRANT ALTER ANY RULE TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT ALTER ANY RULE SET TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT COMMENT ANY TABLE TO "BARSTRMADM";
GRANT CREATE ANY MATERIALIZED VIEW TO "BARSTRMADM";
GRANT CREATE ANY RULE TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT CREATE ANY RULE SET TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT CREATE ANY TABLE TO "BARSTRMADM";
GRANT CREATE DATABASE LINK TO "BARSTRMADM";
GRANT CREATE EVALUATION CONTEXT TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT CREATE RULE TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT CREATE RULE SET TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT CREATE SESSION TO "BARSTRMADM";
exec dbms_aqadm.grant_system_privilege(privilege=>'DEQUEUE_ANY', grantee=>'BARSTRMADM', admin_option=>TRUE);
COMMIT;
exec dbms_aqadm.grant_system_privilege(privilege=>'ENQUEUE_ANY', grantee=>'BARSTRMADM', admin_option=>TRUE);
COMMIT;;
GRANT EXECUTE ANY RULE TO "BARSTRMADM" WITH ADMIN OPTION;
GRANT EXECUTE ANY RULE SET TO "BARSTRMADM" WITH ADMIN OPTION;
exec dbms_aqadm.grant_system_privilege(privilege=>'MANAGE_ANY', grantee=>'BARSTRMADM', admin_option=>TRUE);
COMMIT;
GRANT RESTRICTED SESSION TO "BARSTRMADM";
GRANT SELECT ANY DICTIONARY TO "BARSTRMADM";
GRANT SELECT ANY TRANSACTION TO "BARSTRMADM";
GRANT UNLIMITED TABLESPACE TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ACCESION_NUMBERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ALR_MERGED_IDS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ALR_SCANNED_IDS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_AUTHORS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_BACKGROUNDERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_BACKG_SPECIALIZATION" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_BACKG_TERMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_COMPI_COND_CATEGORIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_COMPI_DEVELOP" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_COMPI_PATENTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_COMP_INTELLIGENCE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_CONDITIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_FREE_TABLES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_SECTIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_SECTION_BACKGRS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_SECTION_FREE_TABLES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_SECTION_IMAGE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_TERMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_TERM_FREE_TABLES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BGR_TERM_IMAGE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BIBLIOGRAPHY_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOLOGIC_PROCESSES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOMARKER_KITS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOMARKER_KIT_NAMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOMARKER_NAMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOMARKER_RELAT_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOMARKER_USE_REFERENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_BIOLOGIC_PROCESSES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_ENVIRONMENT_MODIFIERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_KIT_ORGANIZATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_MECHANISMS_MODIFIERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_ORGANIZATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_USE_DEV_MILESTONES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_USE_DSTM_PAT_FAMILIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_USE_DSTM_REFERENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_USE_DST_PAT_FAMILIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_BIOM_USE_DST_REFERENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_DESC_OR_EN_CHANGE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_ENVIRONMENTAL_MODIFIERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_ROLES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_SUBSTRATES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_TECHNIQUES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_TECHNIQUE_SUBSTRATES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_TECHNIQUE_SUPPLIERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."BMA_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CLS_CLINICAL_STUDIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CLS_GROUPS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CLS_GROUP_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CLS_INTERVENTION_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CLS_PUBLICATION_STATUS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CLS_STUDY_CONDITIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CMI_MODIFIED_IDS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CONG_EDITIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CONG_LOCATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."COUNTRIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."COUNTRY_GROUPS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."COUNTRY_GROUP_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."CURRENCIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."DTC_DESCRIPTORS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."DTC_VALUES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."EDITORIAL_LAST_EXPORT_DATE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ENZYMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."EXPRESSIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."EXP_MATERIALS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."EXP_METH_STUDIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."EXP_PARAMETERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GENERIC_NAME_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GENES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GENES_CONDITIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GENES_EXPRESSIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GENES_RELATED" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GENES_REL_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_DISEASE_ASSOCIATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GATEWAYS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GATEWAY_CONDS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GATEWAY_MOL_PATHS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GENES_PROTEINS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GENETIC_VARIANTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GEN_VAR_DISEASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GEN_VAR_DIS_PAT_FAMILIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GEN_VAR_DIS_PAT_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GEN_VAR_DIS_REFERENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GEN_VAR_DIS_REF_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_GEN_VAR_EFFECTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_MOLECULAR_PATHWAYS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_MOL_PATH_IMAGES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_NO_CLINICAL_CONDITIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_SYNONYMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_TARGET_DISEASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_VALIDITIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."GEN_VARIATION_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."MET_SCHEMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."MET_SCHEME_ENZYME" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."MET_SCHEME_PRO" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."MET_SCHEME_REF" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."MILESTONES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."NAT_LOCATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."NAT_NATURAL_SOURCES_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."NAT_ORGANISMS_LOCATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."NAT_SOURCES_LINKS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."NAT_SYNONYMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ORGANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ORGAN_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ORG_ORGAN_ECONOMY" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ORG_ORGAN_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ORG_RELAT_ORGANIZATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."ORG_RELAT_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_CLASSIFICATION_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_DDP_PROCESSES_LOGS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_FAM_APPLICANTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_FAM_BIOMARKERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_FAM_CONDITIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_FAM_GENES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_FAM_INVENTORS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_FAM_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_INVENTORS_FILTERED" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_LEGAL_STATUS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_LEGAL_STATUS_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_ORIGINAL_ABSTRACTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_PATENTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_PATENT_CLASSIFICATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PAT_SUBJECT_MATTERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PHASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_ADMIN_ROUTES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_AGE_GROUPS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_ANIMAL_HUMAN" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_COMPARTMENTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_HEPATIC_FAILURES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_INTERACTING_AGENTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_MESURED_AS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_METABOLIC_STATES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_PARAMETERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_RACES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_RESULT_MODEL" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_RESULT_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_SEX" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_STUDIES_MODEL" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_STUDIES_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PKL_UNITS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_CATEGORY_DESCRIPTORS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_CHEM_NAMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_CONFORMATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_DESCRIPTORS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_DEVELOP_STATUS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_DEV_STATUS_ADMIN_ROUTES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_METABOLIC_NAMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_MILESTONE_COUNTRIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_MILESTONE_ORGANIZATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_NAME_CHANGE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_NAME_DERIVS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_ORG_RELATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_PRODUCT_MILESTONES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_PRODUCT_NAMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_PRODUCT_NAMES_COMPACT" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_PRODUCT_PRESCRIPTION_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_PRODUCT_TEXTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_RELAT_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_RELAT_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_SALES_GEOGRAPHIC_AREA" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_SALES_ORGANIZATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_SOFTWARES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRO_SUMMARIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRT_PROTEIN_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRT_PROTEIN_ORGANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRT_SYNONYMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PRT_TARGET_DISEASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."PUBLISHERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_AUTHORS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_AUTHORS_FILTERED" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_GENES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_ORGANIZATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_ORIGINAL_ABSTRACTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_PROTEINS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_THER_ACTIVITIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REF_VALID_INTEGRITY_REFERENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."REPORT_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SEQUENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SEQUENCE_CLASSES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."STANDARDIZED_STRUCTURES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SYN_SCHEMES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SYN_SCHEME_PAT_FAMILIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SYN_SCHEME_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SYN_SCHEME_REFERENCES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SYN_SUPPLIERS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."SYN_SYNTHESIS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_NAME_CHANGE" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_TARGETS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_TARGET_DISEASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_TARGET_GENES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_TARGET_IMAGES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_TARGET_IMAGE_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_TARGET_PROTEINS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TAR_VALIDITY_STATUS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TEXT_PRODUCTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_DISEASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_DISEASES_GATEWAYS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_INDICATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_INDICATION_DISEASES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_INDICATION_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_NOT_CLASSIFIED_INDICATIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_PRODUCT_CATEGORIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_RELAT_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_REL_DISEASE_CONDITION" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."THE_THER_ACTIVITIES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TOX_TOXIC_REACTIONS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TOX_TOXIC_REACTION_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TOX_TOXIC_RESULTS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TOX_TOXIC_RESULT_MECHANISMS" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."TOX_TOXIC_RESULT_REPORT_TYPES" TO "BARSTRMADM";
GRANT SELECT ON "PROUS_EDITORIAL_CONTENT"."UNITS_MFLINE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."AQ$INTERNET_USERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."AQ$_PROPAGATION_STATUS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_CHANGE_HANDLERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_CONFLICT_COLUMNS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_DML_CONF_HANDLERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_DML_HANDLERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_ENQUEUE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_ERROR" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_ERROR_MESSAGES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_EXECUTE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_INSTANTIATED_GLOBAL" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_INSTANTIATED_OBJECTS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_INSTANTIATED_SCHEMAS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_KEY_COLUMNS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_PARAMETERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_PROGRESS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_SPILL_TXN" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_APPLY_TABLE_COLUMNS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_AQ_AGENTS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_AQ_AGENT_PRIVS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_CAPTURE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_CAPTURE_EXTRA_ATTRIBUTES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_CAPTURE_PARAMETERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_CAPTURE_PREPARED_DATABASE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_CAPTURE_PREPARED_SCHEMAS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_CAPTURE_PREPARED_TABLES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_COMPARISON" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_COMPARISON_COLUMNS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_COMPARISON_ROW_DIF" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_COMPARISON_SCAN" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_COMPARISON_SCAN_SUMMARY" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_COMPARISON_SCAN_VALUES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_DB_LINKS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_EVALUATION_CONTEXTS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_EVALUATION_CONTEXT_TABLES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_EVALUATION_CONTEXT_VARS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_PROPAGATION" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_QUEUES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_QUEUE_PUBLISHERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_QUEUE_SCHEDULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_QUEUE_SUBSCRIBERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_QUEUE_TABLES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RECOVERABLE_SCRIPT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RECOVERABLE_SCRIPT_BLOCKS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RECOVERABLE_SCRIPT_ERRORS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RECOVERABLE_SCRIPT_HIST" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RECOVERABLE_SCRIPT_PARAMS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_REGISTERED_ARCHIVED_LOG" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RULESETS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RULE_SETS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_RULE_SET_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_SCHEDULER_JOBS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_ADD_COLUMN" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_ADMINISTRATOR" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_COLUMNS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_DELETE_COLUMN" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_GLOBAL_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_KEEP_COLUMNS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_MESSAGE_CONSUMERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_MESSAGE_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_NEWLY_SUPPORTED" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_RENAME_COLUMN" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_RENAME_SCHEMA" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_RENAME_TABLE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_SCHEMA_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_SPLIT_MERGE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_SPLIT_MERGE_HIST" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_STMTS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_STMT_HANDLERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TABLE_RULES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TP_COMPONENT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TP_COMPONENT_LINK" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TP_COMPONENT_STAT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TP_DATABASE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TP_PATH_BOTTLENECK" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TP_PATH_STAT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TRANSFORMATIONS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_TRANSFORM_FUNCTION" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_STREAMS_UNSUPPORTED" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_SYNC_CAPTURE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."DBA_SYNC_CAPTURE_PREPARED_TABS" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_APPLY_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_AQ" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_AQADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_AQELM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_AQIN" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_AQ_BQVIEW" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_CAPTURE_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_CAPTURE_SWITCH_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_FLASHBACK" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_LOCK" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_PROPAGATION_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_RULE_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_STREAMS_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_STREAMS_ADVISOR_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_STREAMS_HANDLER_ADM" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_STREAMS_MESSAGING" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_STREAMS_RPC" TO "BARSTRMADM";
GRANT EXECUTE ON "SYS"."DBMS_TRANSFORM" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$AQ" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$BUFFERED_PUBLISHERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$BUFFERED_QUEUES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$BUFFERED_SUBSCRIBERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_APPLY_COORDINATOR" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_APPLY_READER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_APPLY_SERVER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_CAPTURE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_MESSAGE_TRACKING" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_POOL_STATISTICS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."GV_$STREAMS_TRANSACTION" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."QT163321_BUFFER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."QT163358_BUFFER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."QT163390_BUFFER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$AQ" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$BUFFERED_PUBLISHERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$BUFFERED_QUEUES" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$BUFFERED_SUBSCRIBERS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_APPLY_COORDINATOR" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_APPLY_READER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_APPLY_SERVER" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_CAPTURE" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_MESSAGE_TRACKING" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_POOL_STATISTICS" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."V_$STREAMS_TRANSACTION" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."_DBA_STREAMS_COMPONENT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."_DBA_STREAMS_COMPONENT_EVENT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."_DBA_STREAMS_COMPONENT_LINK" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."_DBA_STREAMS_COMPONENT_PROP" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."_DBA_STREAMS_COMPONENT_STAT" TO "BARSTRMADM";
GRANT SELECT ON "SYS"."_DBA_STREAMS_TP_COMPONENT_PROP" TO "BARSTRMADM";
GRANT SELECT ON "SYSTEM"."LOGMNR_LOG$" TO "BARSTRMADM";
GRANT SELECT ON "SYSTEM"."LOGMNR_RESTART_CKPT$" TO "BARSTRMADM";
GRANT "DBA" TO "BARSTRMADM";
GRANT "EXECUTE_CATALOG_ROLE" TO "BARSTRMADM";
GRANT "RESOURCE" TO "BARSTRMADM";
GRANT "SELECT_CATALOG_ROLE" TO "BARSTRMADM";
