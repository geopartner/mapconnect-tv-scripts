
-- Afvikles stepvis efter alle navn erstattet i GC2 database 
--  erstat <vw_cc_projecname> med det view der er skabt i CloudConnect database, der udstiller projektdata
--  <mv_files_projecname> med navn hvor projectname svarer til den aktuelle database.
--  <databasenavn> erstattes med navnet på den aktuelle database 
--  <token> med aktuel token fra CloudConnect
--  <apikey> med aktuel apikey opsat i CloudConnect

--1
CREATE EXTENSION IF NOT EXISTS postgres_fdw
    SCHEMA public
    VERSION "1.1";

-- 2 Foreign Server: cloud_connect_aws

-- DROP SERVER IF EXISTS cloud_connect_aws

CREATE SERVER cloud_connect_aws
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (dbname 'cloudconnect', extensions 'postgis', fetch_size '10000', host 'ler-db-cluster.cluster-cuqhu7rzbx4y.eu-north-1.rds.amazonaws.com', port '5432', updatable 'false');

ALTER SERVER cloud_connect_aws
    OWNER TO <databasenavn>;

COMMENT ON SERVER cloud_connect_aws
    IS 'Denne FDW benyttes til at hente Cloud connect data som kan vises på kundernes WEB-gis portal.';
	
--3 user mapping
CREATE USER MAPPING FOR gc2 SERVER cloud_connect_aws
    OPTIONS ("user" 'postgres', password 'qBXbFSjvhx8H9dv');	
	
--4 
CREATE USER MAPPING FOR postgres SERVER cloud_connect_aws;

--5 
-- FOREIGN TABLE: dandas.<vw_cc_projecname>

-- DROP FOREIGN TABLE IF EXISTS dandas.<vw_cc_projecname>;


CREATE FOREIGN TABLE IF NOT EXISTS dandas.<vw_cc_projecname>(
    pk integer OPTIONS (column_name 'pk') NULL,
    filename text OPTIONS (column_name 'filename') NULL COLLATE pg_catalog."default",
    filetype text OPTIONS (column_name 'filetype') NULL COLLATE pg_catalog."default",
    folder text OPTIONS (column_name 'folder') NULL COLLATE pg_catalog."default",
    foldername text OPTIONS (column_name 'foldername') NULL COLLATE pg_catalog."default"
)
    SERVER cloud_connect_aws
    OPTIONS (schema_name 'public', table_name '<vw_cc_projecname>');

ALTER FOREIGN TABLE dandas.<vw_cc_projecname>
    OWNER TO <databasenavn>;

GRANT ALL ON TABLE dandas.<vw_cc_projecname> TO <databasenavn>;


--6
-- View: dandas.mv_cc_projectfiles

-- DROP MATERIALIZED VIEW IF EXISTS dandas.mv_cc_projectfiles

CREATE MATERIALIZED VIEW IF NOT EXISTS dandas.mv_cc_projectfiles
TABLESPACE pg_default
AS
 SELECT vw_cc_projectfiles.pk AS gid,
    vw_cc_projectfiles.filename AS filnavn,
    vw_cc_projectfiles.filetype,
    vw_cc_projectfiles.folder,
    vw_cc_projectfiles.foldername AS sti,
    true AS file_exists_on_ftp
   FROM dandas.vw_cc_projectfiles 
WITH DATA;

ALTER TABLE IF EXISTS dandas.mv_cc_projectfiles
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.mv_cc_projectfiles TO gc2;


CREATE INDEX idx_cc_projectfiles_file_sti
    ON dandas.mv_cc_projectfiles USING btree
    (sti COLLATE pg_catalog."default")
    TABLESPACE pg_default;
CREATE INDEX iidx_cc_projectfiles_filnavn
    ON dandas.mv_cc_projectfiles USING btree
    (filnavn COLLATE pg_catalog."default")
    TABLESPACE pg_default;

--7 view   IKKE OPRETTET
-- View: dandas.broendrapporter_fejlliste

-- DROP VIEW dandas.broendrapporter_fejlliste;

CREATE OR REPLACE VIEW dandas.broendrapporter_fejlliste
 AS
 SELECT ddg_brondrapport.ogc_fid AS gid,
    ddg_brondrapport.knudeid,
    ddg_brondrapport.rapportid,
    ddg_brondrapport.datorapport,
    ddg_brondrapport.rapporttype,
    ddg_brondrapport.knudesystem,
    ddg_brondrapport.knudekategori,
    ddg_brondrapport.rapportnr,
    ddg_brondrapport.dokumentnavn,
    ddg_brondrapport.the_geom,
    NULL::text AS billeder
   FROM dandas.ddg_brondrapport
  WHERE ddg_brondrapport.dokumentnavn IS NULL AND ddg_brondrapport.rapportnr IS NULL;

ALTER TABLE dandas.broendrapporter_fejlliste
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.broendrapporter_fejlliste TO gc2;

-- 8 
-- View: dandas.tv_observationer_uden_tv ( skal med i build)

-- DROP VIEW dandas.tv_observationer_uden_tv;

CREATE OR REPLACE VIEW dandas.tv_observationer_uden_tv
 AS
 SELECT gp_tv_observationer.ogc_fid AS gid,
    gp_tv_observationer."LerGeom" as the_geom,
    gp_tv_observationer.filmfil,
    gp_tv_observationer.datorapport,
    gp_tv_observationer.rapportnr,
    gp_tv_observationer.lokalitet,
    gp_tv_observationer.entreprenoerid,
    gp_tv_observationer."position",
    gp_tv_observationer.tekstfil,
    gp_tv_observationer.tvbemaerk,
    gp_tv_observationer.tvobskode,
    gp_tv_observationer.tvobsklasse,
    gp_tv_observationer.rapporttypekode,
    gp_tv_observationer.kundenavn,
    gp_tv_observationer.sagsnavn,
    gp_tv_observationer.operatoer,
    gp_tv_observationer.aarsag,
    gp_tv_observationer.inspmetodekode,
    gp_tv_observationer.systemkode,
    gp_tv_observationer.renset,
    gp_tv_observationer.medstroems,
    gp_tv_observationer.datoudfoert,
    gp_tv_observationer.brugkode,
    gp_tv_observationer.vejrligkode,
    gp_tv_observationer.medienr,
    gp_tv_observationer.fi,
    gp_tv_observationer.ledningsnr,
    gp_tv_observationer.startpunktkode,
    gp_tv_observationer.slutpunktkode,
    gp_tv_observationer.startpunktnr,
    gp_tv_observationer.slutpunktnr,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.<mv_files_projecname> ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.startpunktnr, '%', gp_tv_observationer.slutpunktnr, '%') AND ftp_files_1.sti = 'jpg_tvrapport'::text) subq
          GROUP BY subq.group_arg) AS billeder,
    ( SELECT concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', ftp_files_1.filnavn, '?token=<token>&apikey=<apikey>') AS concat
           FROM dandas.<mv_files_projecname> ftp_files_1
          WHERE (ftp_files_1.filnavn ~~* replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.pdf'::text) OR ftp_files_1.filnavn ~~* concat(gp_tv_observationer.startpunktnr, '%', gp_tv_observationer.slutpunktnr, '%')) AND ftp_files_1.sti = 'pdf_tvrapport'::text) AS tv_rapport
   FROM dandas.gp_tv_observationer
     LEFT JOIN dandas.<mv_files_projecname> ON <mv_files_projecname>.filnavn = replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.mp4'::text) AND <mv_files_projecname>.sti = 'mp4'::text AND <mv_files_projecname>.file_exists_on_ftp IS TRUE
  WHERE gp_tv_observationer.filmfil IS NOT NULL AND <mv_files_projecname>.filnavn IS NULL;

ALTER TABLE dandas.tv_observationer_uden_tv
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.tv_observationer_uden_tv TO gc2;
GRANT ALL ON TABLE dandas.tv_observationer_uden_tv TO <databasenavn>;

-- 9 IKKE OPRETTET ddg_ledning.filmfil
-- View: dandas.ledninger_og_stik_med_tv_eksisterende

-- DROP VIEW dandas.ledninger_og_stik_med_tv_eksisterende;

CREATE OR REPLACE VIEW dandas.ledninger_og_stik_med_tv_eksisterende
 AS
 SELECT ddg_ledning.ogc_fid AS gid,
    ddg_ledning.system,
    concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', <mv_files_projecname>.filnavn, '?token=<token>&apikey=<apikey>') AS filmfil,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,                                                                                                       
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=c4b519ec-65e1-4186-accb-c39d74d47a0a'::text) || '"/></a>'::text AS billede
                   FROM dandas.<mv_files_projecname> ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(ddg_ledning."til_brønd", '-', ddg_ledning."fra_brønd", '-', '%.jpg') AND ftp_files_1.sti = 'jpg_tvrapport'::text) subq
          GROUP BY subq.group_arg
         LIMIT 1) AS billeder,
    ( SELECT concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', ftp_files_1.filnavn, '?token=<token>&apikey=<apikey>') AS concat
           FROM dandas.<mv_files_projecname> ftp_files_1
          WHERE ftp_files_1.filnavn ~~* replace(ddg_ledning.filmfil::text, '.mpg'::text, '.pdf'::text) AND ftp_files_1.sti = 'pdf_tvrapport'::text
         LIMIT 1) AS tv_rapport,
    ddg_ledning.filmfil AS filmtag,
    ddg_ledning.the_geom
   FROM dandas.ddg_ledning
     JOIN dandas.<mv_files_projecname> ON <mv_files_projecname>.filnavn = ddg_ledning.filmfil::text
  WHERE ddg_ledning.filmfil IS NOT NULL;

ALTER TABLE dandas.ledninger_og_stik_med_tv_eksisterende
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.ledninger_og_stik_med_tv_eksisterende TO gc2;
GRANT ALL ON TABLE dandas.ledninger_og_stik_med_tv_eksisterende TO <databasenavn>;

-- 10
-- View: dandas.tv_observationer_med_tv

-- DROP VIEW dandas.tv_observationer_med_tv; Skal med i build

CREATE OR REPLACE VIEW dandas.tv_observationer_med_tv
 AS
 SELECT gp_tv_observationer.ogc_fid AS gid,
    gp_tv_observationer."LerGeom" as the_geom,
    gp_tv_observationer.filmfil,
    gp_tv_observationer.datorapport,
    gp_tv_observationer.rapportnr,
    gp_tv_observationer.lokalitet,
    gp_tv_observationer.entreprenoerid,
    gp_tv_observationer."position",
    gp_tv_observationer.tekstfil,
    gp_tv_observationer.tvbemaerk,
    gp_tv_observationer.tvobskode,
    gp_tv_observationer.tvobsklasse,
    gp_tv_observationer.rapporttypekode,
    gp_tv_observationer.kundenavn,
    gp_tv_observationer.sagsnavn,
    gp_tv_observationer.operatoer,
    gp_tv_observationer.aarsag,
    gp_tv_observationer.inspmetodekode,
    gp_tv_observationer.systemkode,
    gp_tv_observationer.renset,
    gp_tv_observationer.medstroems,
    gp_tv_observationer.datoudfoert,
    gp_tv_observationer.brugkode,
    gp_tv_observationer.vejrligkode,
    gp_tv_observationer.medienr,
    gp_tv_observationer.fi,
    gp_tv_observationer.ledningsnr,
    gp_tv_observationer.startpunktkode,
    gp_tv_observationer.slutpunktkode,
    gp_tv_observationer.startpunktnr,
    gp_tv_observationer.slutpunktnr,
        CASE
            WHEN gp_tv_observationer."position"::numeric < 2::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.mp4'::text), '?token=<token>&apikey=<apikey>'::text, '#t=', '0,2')::character varying
            WHEN gp_tv_observationer."position"::numeric < 100::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.mp4'::text), '?token=<token>&apikey=<apikey>'::text, '#t=', "right"(gp_tv_observationer."position"::character varying::text, 2)::integer - 2, ',', "right"(gp_tv_observationer."position"::character varying::text, 2)::integer + 2)::character varying
            WHEN gp_tv_observationer."position"::numeric > 99::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.mp4'::text), '?token=<token>&apikey=<apikey>'::text, '#t=', "left"(gp_tv_observationer."position"::character varying::text, '-2'::integer)::integer * 60 + "right"(gp_tv_observationer."position"::character varying::text, 2)::integer - 2, ',', "left"(gp_tv_observationer."position"::character varying::text, '-2'::integer)::integer * 60 + "right"(gp_tv_observationer."position"::character varying::text, 2)::integer + 2)::character varying
            ELSE concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.mp4'::text), '#t=', '0,2', '?token=<token>&apikey=<apikey>'::text)::character varying
        END AS videolink,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.<mv_files_projecname> ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.startpunktnr, '-', gp_tv_observationer.slutpunktnr, '-', '%.jpg') AND ftp_files_1.sti = 'jpg_tvrapport'::text) subq
          GROUP BY subq.group_arg) AS billeder,
    ( SELECT concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', ftp_files_1.filnavn) AS concat
           FROM dandas.<mv_files_projecname> ftp_files_1
          WHERE ftp_files_1.filnavn ~~* replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.pdf'::text) AND ftp_files_1.sti = 'pdf_tvrapport'::text) AS tv_rapport
   FROM dandas.gp_tv_observationer
     JOIN dandas.<mv_files_projecname> ON <mv_files_projecname>.filnavn = replace(gp_tv_observationer.filmfil::text, '.mpg'::text, '.mp4'::text) AND <mv_files_projecname>.sti = 'mp4'::text AND <mv_files_projecname>.file_exists_on_ftp IS TRUE
  WHERE gp_tv_observationer.filmfil IS NOT NULL;

ALTER TABLE dandas.tv_observationer_med_tv
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.tv_observationer_med_tv TO gc2;
GRANT ALL ON TABLE dandas.tv_observationer_med_tv TO grundfos;

--11 IKKE OPRETTET ddg_ledning.film findes ikke
-- View: dandas.ledninger_og_stik_med_tv_ikke_eksisterende

-- DROP VIEW dandas.ledninger_og_stik_med_tv_ikke_eksisterende;

CREATE OR REPLACE VIEW dandas.ledninger_og_stik_med_tv_ikke_eksisterende
 AS
 SELECT ddg_ledning.ogc_fid AS gid,
    ddg_ledning.system,
    ddg_ledning.filmfil AS filmtag,
    ddg_ledning.the_geom
   FROM dandas.ddg_ledning
     LEFT JOIN dandas.<mv_files_projecname> ON <mv_files_projecname>.filnavn = ddg_ledning.filmfil::text
  WHERE ddg_ledning.filmfil IS NOT NULL AND <mv_files_projecname>.filnavn IS NULL;

ALTER TABLE dandas.ledninger_og_stik_med_tv_ikke_eksisterende
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.ledninger_og_stik_med_tv_ikke_eksisterende TO gc2;
GRANT ALL ON TABLE dandas.ledninger_og_stik_med_tv_ikke_eksisterende TO grundfos;
-- 12 IKKE OPRETTET dandas.ddg_brondrapport findes ikke
--  View: dandas.broendrapporter_med_pdf 

-- DROP VIEW dandas.broendrapporter_med_pdf;

CREATE OR REPLACE VIEW dandas.broendrapporter_med_pdf
 AS
 SELECT ddg_brondrapport.ogc_fid AS gid,
    ddg_brondrapport.knudeid,
    ddg_brondrapport.rapportid,
    ddg_brondrapport.datorapport,
    ddg_brondrapport.rapporttype,
    ddg_brondrapport.knudesystem,
    ddg_brondrapport.knudekategori,
    ddg_brondrapport.rapportnr,
    ddg_brondrapport.dokumentnavn,
    ddg_brondrapport.the_geom,  
    concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', <mv_files_projecname>.filnavn, '?token=<token>&apikey=<apikey>') AS dokumentlink,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.<mv_files_projecname> ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(ddg_brondrapport.dokumentnavn, '%') AND ddg_brondrapport.dokumentnavn IS NOT NULL AND ftp_files_1.sti = 'jpg_broendrapport'::text OR ftp_files_1.filnavn ~~* concat(ddg_brondrapport.rapportnr, '%') AND ddg_brondrapport.rapportnr IS NOT NULL AND ftp_files_1.sti = 'jpg_broendrapport'::text) subq
          GROUP BY subq.group_arg) AS billeder
   FROM dandas.ddg_brondrapport
     JOIN dandas.<mv_files_projecname> ON <mv_files_projecname>.filnavn ~~* concat(ddg_brondrapport.dokumentnavn, '%') AND ddg_brondrapport.dokumentnavn IS NOT NULL AND <mv_files_projecname>.sti = 'pdf_broendrapport'::text AND <mv_files_projecname>.file_exists_on_ftp IS TRUE OR <mv_files_projecname>.filnavn ~~* concat(ddg_brondrapport.rapportnr, '%') AND ddg_brondrapport.rapportnr IS NOT NULL AND <mv_files_projecname>.sti = 'pdf_broendrapport'::text AND <mv_files_projecname>.file_exists_on_ftp IS TRUE;

ALTER TABLE dandas.broendrapporter_med_pdf
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.broendrapporter_med_pdf TO gc2;
GRANT ALL ON TABLE dandas.broendrapporter_med_pdf TO grundfos;

--
-- 13  IKKE OPRETTET dandas.ddg_brondrapport findes ikke
-- View: dandas.broendrapporter_uden_pdf

-- DROP VIEW dandas.broendrapporter_uden_pdf;

CREATE OR REPLACE VIEW dandas.broendrapporter_uden_pdf
 AS
 SELECT ddg_brondrapport.ogc_fid AS gid,
    ddg_brondrapport.knudeid,
    ddg_brondrapport.rapportid,
    ddg_brondrapport.datorapport,
    ddg_brondrapport.rapporttype,
    ddg_brondrapport.knudesystem,
    ddg_brondrapport.knudekategori,
    ddg_brondrapport.rapportnr,
    ddg_brondrapport.dokumentnavn,
    ddg_brondrapport.the_geom,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '"/></a>'::text AS billede
                   FROM dandas.<mv_files_projecname> ftp_files_1
                  WHERE ddg_brondrapport.dokumentnavn IS NOT NULL AND ftp_files_1.filnavn ~~* concat(ddg_brondrapport.dokumentnavn, '%') AND ftp_files_1.sti = 'jpg_broendrapport'::text OR ddg_brondrapport.rapportnr IS NOT NULL AND ftp_files_1.filnavn ~~* concat(ddg_brondrapport.rapportnr, '%') AND ftp_files_1.sti = 'jpg_broendrapport'::text) subq
          GROUP BY subq.group_arg) AS billeder
   FROM dandas.ddg_brondrapport
     LEFT JOIN dandas.<mv_files_projecname> ON <mv_files_projecname>.filnavn ~~* concat(ddg_brondrapport.dokumentnavn, '%') AND ddg_brondrapport.dokumentnavn IS NOT NULL AND <mv_files_projecname>.sti = 'pdf_broendrapport'::text AND <mv_files_projecname>.file_exists_on_ftp IS TRUE OR <mv_files_projecname>.filnavn ~~* concat(ddg_brondrapport.rapportnr, '%') AND ddg_brondrapport.rapportnr IS NOT NULL AND <mv_files_projecname>.sti = 'pdf_broendrapport'::text AND <mv_files_projecname>.file_exists_on_ftp IS TRUE
  WHERE <mv_files_projecname>.filnavn IS NULL;

ALTER TABLE dandas.broendrapporter_uden_pdf
    OWNER TO gc2;

GRANT ALL ON TABLE dandas.broendrapporter_uden_pdf TO gc2;
GRANT ALL ON TABLE dandas.broendrapporter_uden_pdf TO grundfos;

--	Gruppenavn; TV og Brøndrapporter. Oprettede views / lagnavn: 
	
dandas.tv_observationer_uden_tv -> TV Observationer
dandas.tv_observationer_med_tv -> TV Observationer, uden filmfil


-- IKKE OPRETTET views, fordi ddg_ledning.filmfil findes ikke:
dandas.ledninger_og_stik_med_tv_eksisterende
dandas.ledninger_og_stik_med_tv_ikke_eksisterende

--IKKE RELEVANTE VIEW:
dandas.broendrapporter_med_pdf
dandas.broendrapporter_fejlliste
dandas.broendrapporter_med_pdf
dandas.broendrapporter_uden_pdf
