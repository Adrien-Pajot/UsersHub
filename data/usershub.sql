SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


CREATE SCHEMA IF NOT EXISTS utilisateurs;

SET search_path = utilisateurs, pg_catalog;


CREATE OR REPLACE FUNCTION modify_date_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.date_insert := now();
    NEW.date_update := now();
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION modify_date_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.date_update := now();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE IF NOT EXISTS cor_role_menu (
    id_role integer NOT NULL,
    id_menu integer NOT NULL
);
COMMENT ON TABLE cor_role_menu IS 'gestion du contenu des menus utilisateurs dans les applications';

CREATE TABLE IF NOT EXISTS cor_roles (
    id_role_groupe integer NOT NULL,
    id_role_utilisateur integer NOT NULL
);


DO
$$
BEGIN
CREATE SEQUENCE t_roles_id_seq
    START WITH 1000000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
EXCEPTION WHEN duplicate_table THEN
        -- do nothing, it's already there
END
$$;


CREATE TABLE IF NOT EXISTS t_roles (
    groupe boolean DEFAULT false NOT NULL,
    id_role integer DEFAULT nextval('t_roles_id_seq'::regclass) NOT NULL,
    uuid_role uuid NOT NULL DEFAULT public.uuid_generate_v4(),
    identifiant character varying(100),
    nom_role character varying(50),
    prenom_role character varying(50),
    desc_role text,
    pass character varying(100),
    pass_plus text,
    email character varying(250),
    id_organisme integer,
    organisme character(32),
    id_unite integer,
    remarques text,
    pn boolean,
    session_appli character varying(50),
    date_insert timestamp without time zone,
    date_update timestamp without time zone
);


DO
$$
BEGIN
CREATE SEQUENCE bib_organismes_id_seq
    START WITH 1000000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
EXCEPTION WHEN duplicate_table THEN
        -- do nothing, it's already there
END
$$;


CREATE TABLE IF NOT EXISTS bib_organismes (
    uuid_organisme uuid NOT NULL DEFAULT public.uuid_generate_v4(),
    nom_organisme character varying(100) NOT NULL,
    adresse_organisme character varying(128),
    cp_organisme character varying(5),
    ville_organisme character varying(100),
    tel_organisme character varying(14),
    fax_organisme character varying(14),
    email_organisme character varying(100),
    id_organisme integer DEFAULT nextval('bib_organismes_id_seq'::regclass) NOT NULL
);


CREATE TABLE IF NOT EXISTS bib_droits (
    id_droit integer NOT NULL,
    nom_droit character varying(50),
    desc_droit text
);


DO
$$
BEGIN
CREATE SEQUENCE bib_unites_id_seq
    START WITH 1000000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
EXCEPTION WHEN duplicate_table THEN
        -- do nothing, it's already there
END
$$;


CREATE TABLE IF NOT EXISTS bib_unites (
    nom_unite character varying(50) NOT NULL,
    adresse_unite character varying(128),
    cp_unite character varying(5),
    ville_unite character varying(100),
    tel_unite character varying(14),
    fax_unite character varying(14),
    email_unite character varying(100),
    id_unite integer DEFAULT nextval('bib_unites_id_seq'::regclass) NOT NULL
);


CREATE TABLE IF NOT EXISTS cor_role_droit_application (
    id_role integer NOT NULL,
    id_droit integer NOT NULL,
    id_application integer NOT NULL
);


CREATE TABLE IF NOT EXISTS t_applications (
    id_application integer NOT NULL,
    nom_application character varying(50) NOT NULL,
    desc_application text
);


DO
$$
BEGIN
CREATE SEQUENCE t_applications_id_application_seq
    START WITH 1000000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
EXCEPTION WHEN duplicate_table THEN
        -- do nothing, it's already there
END
$$;
ALTER SEQUENCE t_applications_id_application_seq OWNED BY t_applications.id_application;


CREATE TABLE IF NOT EXISTS t_menus (
    id_menu integer NOT NULL,
    nom_menu character varying(50) NOT NULL,
    desc_menu text,
    id_application integer
);
COMMENT ON TABLE t_menus IS 'table des menus déroulants des applications. Les roles de niveau groupes ou utilisateurs devant figurer dans un menu sont gérés dans la table cor_role_menu_application.';


DO
$$
BEGIN
CREATE SEQUENCE t_menus_id_menu_seq
    START WITH 1000000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
EXCEPTION WHEN duplicate_table THEN
        -- do nothing, it's already there
END
$$;


ALTER SEQUENCE t_menus_id_menu_seq OWNED BY t_menus.id_menu;


ALTER TABLE ONLY t_applications ALTER COLUMN id_application SET DEFAULT nextval('t_applications_id_application_seq'::regclass);


ALTER TABLE ONLY t_menus ALTER COLUMN id_menu SET DEFAULT nextval('t_menus_id_menu_seq'::regclass);


DO
$$
BEGIN
ALTER TABLE ONLY bib_droits
    ADD CONSTRAINT bib_droits_pkey PRIMARY KEY (id_droit);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_droit_application
    ADD CONSTRAINT cor_role_droit_application_pkey PRIMARY KEY (id_role, id_droit, id_application);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_menu
    ADD CONSTRAINT cor_role_menu_pkey PRIMARY KEY (id_role, id_menu);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_roles
    ADD CONSTRAINT cor_roles_pkey PRIMARY KEY (id_role_groupe, id_role_utilisateur);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY bib_organismes
    ADD CONSTRAINT pk_bib_organismes PRIMARY KEY (id_organisme);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY bib_unites
    ADD CONSTRAINT pk_bib_services PRIMARY KEY (id_unite);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY t_roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (id_role);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY t_applications
    ADD CONSTRAINT t_applications_pkey PRIMARY KEY (id_application);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY t_menus
    ADD CONSTRAINT t_menus_pkey PRIMARY KEY (id_menu);
EXCEPTION WHEN invalid_table_definition  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
CREATE TRIGGER modify_date_insert_trigger BEFORE INSERT ON t_roles FOR EACH ROW EXECUTE PROCEDURE modify_date_insert();
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
CREATE TRIGGER modify_date_update_trigger BEFORE UPDATE ON t_roles FOR EACH ROW EXECUTE PROCEDURE modify_date_update();
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_droit_application
    ADD CONSTRAINT cor_role_droit_application_id_application_fkey FOREIGN KEY (id_application) REFERENCES t_applications(id_application) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_droit_application
    ADD CONSTRAINT cor_role_droit_application_id_droit_fkey FOREIGN KEY (id_droit) REFERENCES bib_droits(id_droit) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_droit_application
    ADD CONSTRAINT cor_role_droit_application_id_role_fkey FOREIGN KEY (id_role) REFERENCES t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_menu
    ADD CONSTRAINT cor_role_menu_application_id_menu_fkey FOREIGN KEY (id_menu) REFERENCES t_menus(id_menu) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_role_menu
    ADD CONSTRAINT cor_role_menu_application_id_role_fkey FOREIGN KEY (id_role) REFERENCES t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_roles
    ADD CONSTRAINT cor_roles_id_role_groupe_fkey FOREIGN KEY (id_role_groupe) REFERENCES t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY cor_roles
    ADD CONSTRAINT cor_roles_id_role_utilisateur_fkey FOREIGN KEY (id_role_utilisateur) REFERENCES t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY t_menus
    ADD CONSTRAINT t_menus_id_application_fkey FOREIGN KEY (id_application) REFERENCES t_applications(id_application) ON UPDATE CASCADE ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY t_roles
    ADD CONSTRAINT t_roles_id_organisme_fkey FOREIGN KEY (id_organisme) REFERENCES bib_organismes(id_organisme) ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;


DO
$$
BEGIN
ALTER TABLE ONLY t_roles
    ADD CONSTRAINT t_roles_id_unite_fkey FOREIGN KEY (id_unite) REFERENCES bib_unites(id_unite) ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object  THEN
        -- do nothing, it's already there
END
$$;

DO
$$
BEGIN
CREATE OR REPLACE VIEW v_userslist_forall_menu AS
 SELECT a.groupe,
    a.id_role,
    a.uuid_role,
    a.identifiant,
    a.nom_role,
    a.prenom_role,
    (upper(a.nom_role::text) || ' '::text) || a.prenom_role::text AS nom_complet,
    a.desc_role,
    a.pass,
    a.email,
    a.id_organisme,
    a.organisme,
    a.id_unite,
    a.remarques,
    a.pn,
    a.session_appli,
    a.date_insert,
    a.date_update,
    a.id_menu
   FROM ( SELECT u.groupe,
            u.id_role,
            u.uuid_role,
            u.identifiant,
            u.nom_role,
            u.prenom_role,
            u.desc_role,
            u.pass,
            u.email,
            u.id_organisme,
            u.organisme,
            u.id_unite,
            u.remarques,
            u.pn,
            u.session_appli,
            u.date_insert,
            u.date_update,
            c.id_menu
           FROM utilisateurs.t_roles u
             JOIN utilisateurs.cor_role_menu c ON c.id_role = u.id_role
          WHERE u.groupe = false
        UNION
         SELECT u.groupe,
            u.id_role,
            u.uuid_role,
            u.identifiant,
            u.nom_role,
            u.prenom_role,
            u.desc_role,
            u.pass,
            u.email,
            u.id_organisme,
            u.organisme,
            u.id_unite,
            u.remarques,
            u.pn,
            u.session_appli,
            u.date_insert,
            u.date_update,
            c.id_menu
           FROM utilisateurs.t_roles u
             JOIN utilisateurs.cor_roles g ON g.id_role_utilisateur = u.id_role
             JOIN utilisateurs.cor_role_menu c ON c.id_role = g.id_role_groupe
          WHERE u.groupe = false) a;
    EXCEPTION WHEN duplicate_object  THEN
    -- do nothing, it's already there
END
$$;

DO
$$
BEGIN
CREATE OR REPLACE VIEW v_userslist_forall_applications AS 
 SELECT a.groupe,
 a.id_role,
 a.identifiant,
 a.nom_role,
 a.prenom_role,
 a.desc_role,
 a.pass,
 a.email,
 a.id_organisme,
 a.organisme,
 a.id_unite,
 a.remarques,
 a.pn,
 a.session_appli,
 a.date_insert,
 a.date_update,
 max(a.id_droit) AS id_droit_max,
 a.id_application
 FROM ( SELECT u.groupe,
 u.id_role,
 u.identifiant,
 u.nom_role,
 u.prenom_role,
 u.desc_role,
 u.pass,
 u.email,
 u.id_organisme,
 u.organisme,
 u.id_unite,
 u.remarques,
 u.pn,
 u.session_appli,
 u.date_insert,
 u.date_update,
 c.id_droit,
 c.id_application
 FROM t_roles u
 JOIN cor_role_droit_application c ON c.id_role = u.id_role
 WHERE u.groupe = false
 UNION
 SELECT u.groupe,
 u.id_role,
 u.identifiant,
 u.nom_role,
 u.prenom_role,
 u.desc_role,
 u.pass,
 u.email,
 u.id_organisme,
 u.organisme,
 u.id_unite,
 u.remarques,
 u.pn,
 u.session_appli,
 u.date_insert,
 u.date_update,
 c.id_droit,
 c.id_application
 FROM t_roles u
 JOIN cor_roles g ON g.id_role_utilisateur = u.id_role
 JOIN cor_role_droit_application c ON c.id_role = g.id_role_groupe
 WHERE u.groupe = false) a
 GROUP BY a.groupe, a.id_role, a.identifiant, a.nom_role, a.prenom_role, a.desc_role, a.pass, a.email, a.id_organisme, a.organisme, a.id_unite, a.remarques, a.pn, a.session_appli, a.date_insert, a.date_update, a.id_application;
EXCEPTION WHEN duplicate_object  THEN
    -- do nothing, it's already there
END
$$;

DO
$$
BEGIN
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (5, 'validateur', 'Il valide bien sur');
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (4, 'modérateur', 'Peu utilisé');
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (0, 'aucun', 'aucun droit.');
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (1, 'utilisateur', 'Ne peut que consulter');
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (2, 'rédacteur', 'Il possède des droit d''écriture pour créer des enregistrements');
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (6, 'administrateur', 'Il a tous les droits');
INSERT INTO bib_droits (id_droit, nom_droit, desc_droit) VALUES (3, 'référent', 'utilisateur ayant des droits complémentaires au rédacteur (par exemple exporter des données ou autre)');
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN
INSERT INTO bib_organismes (nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, id_organisme) VALUES ('PNF', NULL, NULL, 'Montpellier', NULL, NULL, NULL, 1);
INSERT INTO bib_organismes (nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, id_organisme) VALUES ('Parc National des Ecrins', 'Domaine de Charance', '05000', 'GAP', '04 92 40 20 10', '', '', 2);
INSERT INTO bib_organismes (nom_organisme, adresse_organisme, cp_organisme, ville_organisme, tel_organisme, fax_organisme, email_organisme, id_organisme) VALUES ('Autre', '', '', '', '', '', '', -1);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Virtuel', NULL, NULL, NULL, NULL, NULL, NULL, 1);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Personnels partis', NULL, NULL, NULL, NULL, NULL, NULL, 2);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Stagiaires', NULL, NULL, '', '', NULL, NULL, 3);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Secretariat général', '', '', '', '', NULL, NULL, 4);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Service scientifique', '', '', '', '', NULL, NULL, 5);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Service SI', '', '', '', '', NULL, NULL, 6);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Service Communication', '', '', '', '', NULL, NULL, 7);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Conseil scientifique', '', '', '', NULL, NULL, NULL, 8);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Conseil d''administration', '', '', '', NULL, NULL, NULL, 9);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Partenaire fournisseur', NULL, NULL, NULL, NULL, NULL, NULL, 10);
INSERT INTO bib_unites (nom_unite, adresse_unite, cp_unite, ville_unite, tel_unite, fax_unite, email_unite, id_unite) VALUES ('Autres', NULL, NULL, NULL, NULL, NULL, NULL, -1);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN
INSERT INTO t_applications (id_application, nom_application, desc_application) VALUES (1, 'application utilisateurs', 'application permettant d''administrer la présente base de données.');
INSERT INTO t_applications (id_application, nom_application, desc_application) VALUES (2, 'Taxhub', 'application permettant d''administrer la liste des taxons.');
INSERT INTO t_applications (id_application, nom_application, desc_application) VALUES (14, 'application geonature', 'Application permettant la consultation et la gestion des relevés faune et flore.');
PERFORM pg_catalog.setval('t_applications_id_application_seq', 15, true);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN
INSERT INTO t_roles (groupe, id_role, identifiant, nom_role, prenom_role, desc_role, pass, email, organisme, id_unite, pn, session_appli, date_insert, date_update, id_organisme, remarques) VALUES (true, 20002, NULL, 'grp_en_poste', NULL, 'Tous les agents en poste au PN', NULL, NULL, 'monpn', -1, true, NULL, NULL, NULL, NULL,'groupe test');
INSERT INTO t_roles (groupe, id_role, identifiant, nom_role, prenom_role, desc_role, pass, email, organisme, id_unite, pn, session_appli, date_insert, date_update, id_organisme, remarques, pass_plus) VALUES (false, 1, 'admin', 'Administrateur', 'test', NULL, '21232f297a57a5a743894a0e4a801fc3', '', 'Parc national des Ecrins', 1, true, NULL, NULL, NULL, -1,'utilisateur test à modifier', '$2y$13$TMuRXgvIg6/aAez0lXLLFu0lyPk4m8N55NDhvLoUHh/Ar3rFzjFT.');
INSERT INTO t_roles (groupe, id_role, identifiant, nom_role, prenom_role, desc_role, pass, email, organisme, id_unite, pn, session_appli, date_insert, date_update, id_organisme, remarques) VALUES (false, 3, 'partenaire', 'Partenaire', 'test', NULL, '5bd40a8524882d75f3083903f2c912fc', '', 'Autre', -1, true, NULL, NULL, NULL, -1,'utilisateur test à modifier ou supprimer');
INSERT INTO t_roles (groupe, id_role, identifiant, nom_role, prenom_role, desc_role, pass, email, organisme, id_unite, pn, session_appli, date_insert, date_update, id_organisme, remarques) VALUES (false, 2, 'agent', 'Agent', 'test', NULL, 'b33aed8f3134996703dc39f9a7c95783', '', 'Parc national des Ecrins', 1, true, NULL, NULL, NULL, -1,'utilisateur test à modifier ou supprimer');
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN 
INSERT INTO cor_role_droit_application (id_role, id_droit, id_application) VALUES (1, 6, 1);
INSERT INTO cor_role_droit_application (id_role, id_droit, id_application) VALUES (1, 6, 2);
INSERT INTO cor_role_droit_application (id_role, id_droit, id_application) VALUES (1, 6, 14);
INSERT INTO cor_role_droit_application (id_role, id_droit, id_application) VALUES (20002, 3, 14);
INSERT INTO cor_role_droit_application (id_role, id_droit, id_application) VALUES (2, 2, 14);
INSERT INTO cor_role_droit_application (id_role, id_droit, id_application) VALUES (3, 1, 14);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN 
INSERT INTO t_menus (id_menu, nom_menu, desc_menu, id_application) VALUES (9, 'faune - Observateurs', 'listes des observateurs faune', 14);
INSERT INTO t_menus (id_menu, nom_menu, desc_menu, id_application) VALUES (10, 'flore - Observateurs', 'Liste des observateurs flore', 14);
PERFORM pg_catalog.setval('t_menus_id_menu_seq', 11, true);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN
INSERT INTO cor_role_menu (id_role, id_menu) VALUES (1, 10);
INSERT INTO cor_role_menu (id_role, id_menu) VALUES (1, 9);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;


DO
$$
BEGIN
INSERT INTO cor_roles (id_role_groupe, id_role_utilisateur) VALUES (20002, 1);
EXCEPTION WHEN unique_violation  THEN
        RAISE NOTICE 'Tentative d''insertion de valeur existante';
END
$$;