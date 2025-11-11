-- FUNCTION: dandas.build()

-- DROP FUNCTION IF EXISTS dandas.build();

CREATE OR REPLACE FUNCTION dandas.build(
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

BEGIN
----------------------------------------------------------------------------------------------------
-- Byg views til brug for webkort
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Indeksering
----------------------------------------------------------------------------------------------------

-- dandas.ddg_knude
CREATE INDEX IF NOT EXISTS idx_ddg_knude_system
ON dandas.ddg_knude USING btree
(system COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_knude_status
ON dandas.ddg_knude USING btree
(status COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_knude_ejer
ON dandas.ddg_knude USING btree
(ejer COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

-- dandas.ddg_knude_text
CREATE INDEX IF NOT EXISTS idx_ddg_knude_text_system
ON dandas.ddg_knude_text USING btree
(system COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_knude_text_status
ON dandas.ddg_knude_text USING btree
(status COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_knude_text_ejer
ON dandas.ddg_knude_text USING btree
(ejer COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

-- dandas.ddg_knude_txtboks
CREATE INDEX IF NOT EXISTS idx_ddg_knude_txtboks_system
ON dandas.ddg_knude_txtboks USING btree
(system COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_knude_txtboks_status
ON dandas.ddg_knude_txtboks USING btree
(status COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_knude_txtboks_ejer
ON dandas.ddg_knude_txtboks USING btree
(ejer COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

-- dandas.ddg_ledning
CREATE INDEX IF NOT EXISTS idx_ddg_ledning_funktion
ON dandas.ddg_ledning USING btree
(funktion COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_system
ON dandas.ddg_ledning USING btree
(system COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_status
ON dandas.ddg_ledning USING btree
(status COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_transport
ON dandas.ddg_ledning USING btree
(transport COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_ejer
ON dandas.ddg_ledning USING btree
(ejer COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

-- dandas.ddg_ledning_strompil
CREATE INDEX IF NOT EXISTS idx_ddg_ledning_strompil_funktion
ON dandas.ddg_ledning_strompil USING btree
(funktion COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_strompil_system
ON dandas.ddg_ledning_strompil USING btree
(system COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_strompil_status
ON dandas.ddg_ledning_strompil USING btree
(status COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_strompil_transport
ON dandas.ddg_ledning_strompil USING btree
(transport COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_strompil_ejer
ON dandas.ddg_ledning_strompil USING btree
(ejer COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

-- dandas.ddg_ledning_hpil
CREATE INDEX IF NOT EXISTS idx_ddg_ledning_hpil_funktion
ON dandas.ddg_ledning_hpil USING btree
(funktion COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_hpil_system
ON dandas.ddg_ledning_hpil USING btree
(system COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_hpil_status
ON dandas.ddg_ledning_hpil USING btree
(status COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_hpil_transport
ON dandas.ddg_ledning_hpil USING btree
(transport COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_ddg_ledning_hpil_ejer
ON dandas.ddg_ledning_hpil USING btree
(ejer COLLATE pg_catalog."default" ASC NULLS LAST)
TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS ddg_ledning_filmfil_idx
    ON dandas.ddg_ledning USING btree
    (filmfil COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
	
CREATE INDEX IF NOT EXISTS idx_ddg_knude_knudenavn
    ON dandas.ddg_knude USING btree
    (knudenavn COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;	

-- MapTv views

-- View: dandas.ledninger_og_stik_med_tv_eksisterende
CREATE OR REPLACE VIEW dandas.ledninger_og_stik_med_tv_eksisterende
 AS
 SELECT ddg_ledning.ogc_fid AS gid,
    ddg_ledning.system,
    ddg_ledning.status,
    ddg_ledning."fra_brønd",
    ddg_ledning."til_brønd",
    ddg_ledning."længde",
    ddg_ledning.kategori,
    ddg_ledning.funktion,
    ddg_ledning.transport,
    ddg_ledning."handelsmål",
    ddg_ledning.diameter_indv,
    ddg_ledning.fald,
    ddg_ledning.materiale,
    ddg_ledning."anlægsår",
    ddg_ledning.ejer,
    ddg_ledning.fysiskindeks,
    concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', mv_cc_files.filnavn, '?token=<token>&apikey=<apikey>') AS filmfil,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    (((((('<a target="_blank" href="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '">'::text) || '<img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>'::text) || '"/></a>'::text AS billede
                   FROM dandas.mv_cc_files ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(ddg_ledning."til_brønd", '-', ddg_ledning."fra_brønd", '-', '%.jpg')) subq
          GROUP BY subq.group_arg) AS billeder,
    ( SELECT ('https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || f.filnavn) || '?token=<token>&apikey=<apikey>'::text AS file_url
           FROM dandas.mv_cc_files f
             JOIN dandas.ddg_ledning l ON lower(f.filnavn) ~~ lower(replace(l.filmfil::text, '.mpg'::text, '.pdf'::text)) OR lower(f.filnavn) ~~ lower(replace(l.filmfil::text, '.mp4'::text, '.pdf'::text))
          WHERE f.filetype = 'pdf'::text
         LIMIT 1) AS tv_rapport,
    ddg_ledning.filmfil AS filmtag,
    ddg_ledning.the_geom
   FROM dandas.ddg_ledning
     JOIN dandas.mv_cc_files ON "substring"(mv_cc_files.filnavn, '^[^.]+\.'::text) = ("substring"(ddg_ledning.filmfil::text, '^[^.]+'::text) || '.'::text)
  WHERE ddg_ledning.filmfil IS NOT NULL AND (mv_cc_files.filetype = 'mp4'::text OR mv_cc_files.filetype = 'mpg'::text) AND (ddg_ledning.status::text = ANY (ARRAY['I brug/drift'::character varying::text, 'Uoplyst'::character varying::text]));
 

-- View: dandas.tv_ledninger_og_stik_fejl
CREATE OR REPLACE VIEW dandas.tv_ledninger_og_stik_fejl
 AS
 SELECT ddg_ledning.ogc_fid AS gid,
    ddg_ledning.system,
    ddg_ledning.id AS lid,
    ddg_ledning."fra_brønd",
    ddg_ledning."til_brønd",
    ddg_ledning.filmfil AS filmtag,
    ddg_ledning.the_geom
   FROM dandas.ddg_ledning
     LEFT JOIN dandas.mv_cc_files cc ON "substring"(cc.filnavn, '^[^.]+'::text) = "substring"(ddg_ledning.filmfil::text, '^[^.]+'::text)
  WHERE ddg_ledning.filmfil IS NOT NULL AND cc.filnavn IS NULL;

ALTER TABLE dandas.tv_ledninger_og_stik_fejl    OWNER TO br_admin;

-- View: dandas.ledninger_og_stik_med_tv_ikke_eksisterende
CREATE OR REPLACE VIEW dandas.ledninger_og_stik_med_tv_ikke_eksisterende
 AS
 SELECT ddg_ledning.ogc_fid AS gid,
    ddg_ledning.system,
    ddg_ledning.status,
    ddg_ledning."fra_brønd",
    ddg_ledning."til_brønd",
    ddg_ledning."længde",
    ddg_ledning.kategori,
    ddg_ledning.funktion,
    ddg_ledning.transport,
    ddg_ledning."handelsmål",
    ddg_ledning.diameter_indv,
    ddg_ledning.fald,
    ddg_ledning.materiale,
    ddg_ledning."anlægsår",
    ddg_ledning.ejer,
    ddg_ledning.fysiskindeks,
    ddg_ledning.the_geom
   FROM dandas.ddg_ledning
     LEFT JOIN dandas.ledninger_og_stik_med_tv_eksisterende ex ON ddg_ledning.id = ex.gid
  WHERE ddg_ledning.filmfil IS NULL OR ex.gid IS NULL;

 
  
-- View: dandas.broendrapporter_med_pdf
CREATE OR REPLACE VIEW dandas.broendrapporter_med_pdf
 AS
 SELECT ddg_brondrapport.ogc_fid AS gid,
    ddg_brondrapport.rapportid,
    ddg_brondrapport.knudenavn,
    ddg_brondrapport.rapporttype,
    ddg_brondrapport.rapportnr,
    to_char(ddg_brondrapport.datoudfoert, 'DD/MM-YYYY'::text) AS datoudfoert,
    knude.system,
    knude.ejer,
    knude.knudetype,
    knude.status,
    ddg_brondrapport.the_geom,
    concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', mv_cc_files.filnavn, '?token=<token>&apikey=<apikey>') AS dokumentlink,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    (((((('<a target="_blank" href="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '">'::text) || '<img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.mv_cc_files ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(ddg_brondrapport.rapportnr, '%') AND ddg_brondrapport.rapportnr IS NOT NULL AND ftp_files_1.filetype = 'jpg'::text OR ftp_files_1.filnavn ~~* concat(ddg_brondrapport.rapportnr, '%') AND ddg_brondrapport.rapportnr IS NOT NULL AND ftp_files_1.filetype = 'jpg'::text) subq
          GROUP BY subq.group_arg) AS billeder
   FROM dandas.ddg_brondrapport
     JOIN dandas.mv_cc_files ON lower(mv_cc_files.filnavn) = lower(ddg_brondrapport.rapportnr::text || '.pdf'::text)
     JOIN dandas.ddg_knude knude ON ddg_brondrapport.knudenavn::text = knude.knudenavn::text;

--view:  dandas.broendrapporter_uden_pdf
CREATE OR REPLACE VIEW dandas.broendrapporter_uden_pdf
 AS
 SELECT ddg_brondrapport.ogc_fid AS gid,
    ddg_brondrapport.rapportid,
    ddg_brondrapport.rapporttype,
    ddg_brondrapport.rapportnr,
    ddg_brondrapport.the_geom,
    to_char(ddg_brondrapport.datoudfoert, 'DD/MM-YYYY'::text) AS datoudfoert,
    knude.knudenavn,
    knude.system,
    knude.ejer,
    knude.knudetype,
    knude.status
   FROM dandas.ddg_brondrapport
     LEFT JOIN dandas.mv_cc_files ON lower(mv_cc_files.filnavn) = lower(ddg_brondrapport.rapportnr::text || '.pdf'::text)
     JOIN dandas.ddg_knude knude ON ddg_brondrapport.knudenavn::text = knude.knudenavn::text
  WHERE mv_cc_files.filnavn IS NULL and ddg_brondrapport.rapportnr IS NOT NULL; 
	 
-- View: dandas.tv_observationer_obskode_grenror
CREATE OR REPLACE VIEW dandas.tv_observationer_obskode_grenror
 AS
 SELECT gp_tv_observationer.ogc_fid AS gid,
    gp_tv_observationer.the_geom,
    gp_tv_observationer.filmfil,
    to_char(gp_tv_observationer.datorapport, 'DD/MM-YYYY'::text) AS datorapport,
    gp_tv_observationer.rapportnr,
    gp_tv_observationer.tvobskode,
    gp_tv_observationer.tvobsklasse,
    gp_tv_observationer.fi,
    gp_tv_observationer.tekstfil,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.mv_cc_files ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.startpunktnr, '-', gp_tv_observationer.slutpunktnr, '-', '%.jpg') AND ftp_files_1.filetype = 'jpg'::text) subq
          GROUP BY subq.group_arg) AS billeder,
    ( SELECT concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', ftp_files_1.filnavn, '?token=<token>&apikey=<apikey>') AS concat
           FROM dandas.mv_cc_files ftp_files_1
          WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.rapportnr::text, '.pdf'::text) AND ftp_files_1.filetype = 'pdf'::text
         LIMIT 1) AS tv_rapport
   FROM dandas.gp_tv_observationer
     LEFT JOIN dandas.mv_cc_files ON mv_cc_files.filnavn = gp_tv_observationer.filmfil::text
  WHERE gp_tv_observationer.tvobskode::text = 'GR'::text;
  
-- tv_observationer_obskode_lav
CREATE OR REPLACE VIEW dandas.tv_observationer_obskode_lav
 AS
 SELECT gp_tv_observationer.ogc_fid AS gid,
    gp_tv_observationer.the_geom,
    gp_tv_observationer.filmfil,
    to_char(gp_tv_observationer.datorapport, 'DD/MM-YYYY'::text) AS datorapport,
    gp_tv_observationer.rapportnr,
    gp_tv_observationer.tvobskode,
    gp_tv_observationer.tvobsklasse,
    gp_tv_observationer.fi,
    gp_tv_observationer.tekstfil,
        CASE
            WHEN gp_tv_observationer."position"::numeric < 2::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '?token=<token>&apikey=<apikey>'::text, '#t=', '0,2')::character varying
            WHEN gp_tv_observationer."position"::numeric < 100::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '?token=<token>&apikey=<apikey>'::text, '#t=', "right"(gp_tv_observationer."position"::character varying::text, 2)::integer - 2, ',', "right"(gp_tv_observationer."position"::character varying::text, 2)::integer + 2)::character varying
            WHEN gp_tv_observationer."position"::numeric > 99::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '?token=<token>&apikey=<apikey>'::text, '#t=', "left"(gp_tv_observationer."position"::character varying::text, '-2'::integer)::integer * 60 + "right"(gp_tv_observationer."position"::character varying::text, 2)::integer - 2, ',', "left"(gp_tv_observationer."position"::character varying::text, '-2'::integer)::integer * 60 + "right"(gp_tv_observationer."position"::character varying::text, 2)::integer + 2)::character varying
            ELSE concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '#t=', '0,2', '?token=<token>&apikey=<apikey>'::text)::character varying
        END AS videolink,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.mv_cc_files ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.startpunktnr, '-', gp_tv_observationer.slutpunktnr, '-', '%.jpg') AND ftp_files_1.filetype = 'jpg'::text) subq
          GROUP BY subq.group_arg) AS billeder,
    ( SELECT concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', ftp_files_1.filnavn, '?token=<token>&apikey=<apikey>') AS concat
           FROM dandas.mv_cc_files ftp_files_1
          WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.rapportnr::text, '.pdf'::text) AND ftp_files_1.filetype = 'pdf'::text
         LIMIT 1) AS tv_rapport
   FROM dandas.gp_tv_observationer
     LEFT JOIN dandas.mv_cc_files ON mv_cc_files.filnavn = gp_tv_observationer.filmfil::text
  WHERE gp_tv_observationer.tvobsklasse IS NULL OR (gp_tv_observationer.tvobsklasse = ANY (ARRAY[0::numeric, 1::numeric, 2::numeric])) AND gp_tv_observationer.tvobskode IS NOT NULL AND gp_tv_observationer.tvobskode::text <> 'GR'::text;

--tv_observationer_obskode_hoj
CREATE OR REPLACE VIEW dandas.tv_observationer_obskode_hoj
 AS
 SELECT gp_tv_observationer.ogc_fid AS gid,
    gp_tv_observationer.the_geom,
    gp_tv_observationer.filmfil,
    to_char(gp_tv_observationer.datorapport, 'DD/MM-YYYY'::text) AS datorapport,
    gp_tv_observationer.rapportnr,
    gp_tv_observationer.tvobskode,
    gp_tv_observationer.tvobsklasse,
    gp_tv_observationer.fi,
    gp_tv_observationer.tekstfil,
        CASE
            WHEN gp_tv_observationer."position"::numeric < 2::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '?token=<token>&apikey=<apikey>'::text, '#t=', '0,2')::character varying
            WHEN gp_tv_observationer."position"::numeric < 100::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '?token=<token>&apikey=<apikey>'::text, '#t=', "right"(gp_tv_observationer."position"::character varying::text, 2)::integer - 2, ',', "right"(gp_tv_observationer."position"::character varying::text, 2)::integer + 2)::character varying
            WHEN gp_tv_observationer."position"::numeric > 99::numeric THEN concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '?token=<token>&apikey=<apikey>'::text, '#t=', "left"(gp_tv_observationer."position"::character varying::text, '-2'::integer)::integer * 60 + "right"(gp_tv_observationer."position"::character varying::text, 2)::integer - 2, ',', "left"(gp_tv_observationer."position"::character varying::text, '-2'::integer)::integer * 60 + "right"(gp_tv_observationer."position"::character varying::text, 2)::integer + 2)::character varying
            ELSE concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', gp_tv_observationer.filmfil, '#t=', '0,2', '?token=<token>&apikey=<apikey>'::text)::character varying
        END AS videolink,
    ( SELECT array_to_string(array_agg(DISTINCT subq.billede), '<p>'::text) AS array_to_string
           FROM ( SELECT 1 AS group_arg,
                    ((((('<a target="_blank" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"><img width="250px" src="https://cloudconnectapi.geopartner.dk/prod/service/file/'::text) || ftp_files_1.filnavn) || '?token=<token>&apikey=<apikey>'::text) || '"/></a>'::text AS billede
                   FROM dandas.mv_cc_files ftp_files_1
                  WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.startpunktnr, '-', gp_tv_observationer.slutpunktnr, '-', '%.jpg') AND ftp_files_1.filetype = 'jpg'::text) subq
          GROUP BY subq.group_arg) AS billeder,
    ( SELECT concat('https://cloudconnectapi.geopartner.dk/prod/service/file/', ftp_files_1.filnavn, '?token=<token>&apikey=<apikey>') AS concat
           FROM dandas.mv_cc_files ftp_files_1
          WHERE ftp_files_1.filnavn ~~* concat(gp_tv_observationer.rapportnr::text, '.pdf'::text) AND ftp_files_1.filetype = 'pdf'::text
         LIMIT 1) AS tv_rapport
   FROM dandas.gp_tv_observationer
     LEFT JOIN dandas.mv_cc_files ON mv_cc_files.filnavn = gp_tv_observationer.filmfil::text
  WHERE gp_tv_observationer.tvobsklasse > 2::numeric AND gp_tv_observationer.tvobskode IS NOT NULL AND gp_tv_observationer.tvobskode::text <> 'GR'::text;

--tv_observationer_kommentar
CREATE OR REPLACE VIEW dandas.tv_observationer_kommentar
 AS
 SELECT gp_tv_observationer.ogc_fid,
    gp_tv_observationer.gid,
    gp_tv_observationer.ledningid,
    gp_tv_observationer.filmfil,
    gp_tv_observationer.datorapport,
    gp_tv_observationer.rapportnr,
    gp_tv_observationer.lokalitet,
    gp_tv_observationer.entreprenoerid,
    gp_tv_observationer."position",
    gp_tv_observationer.maaltstationstart,
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
    gp_tv_observationer.the_geom
   FROM dandas.gp_tv_observationer
  WHERE gp_tv_observationer.tvobskode IS NULL AND gp_tv_observationer.tvbemaerk IS NOT NULL;

  GRANT SELECT ON ALL TABLES IN SCHEMA dandas TO br_projekt;

END;
$BODY$;

ALTER FUNCTION dandas.build()
    OWNER TO gc2;

GRANT EXECUTE ON FUNCTION dandas.build() TO PUBLIC;

GRANT EXECUTE ON FUNCTION dandas.build() TO br_admin;

GRANT EXECUTE ON FUNCTION dandas.build() TO gc2;

