-- Written by Noel Heim, adjustments by John J Czaplewski

DROP SCHEMA IF EXISTS neodb CASCADE;

CREATE SCHEMA neodb;
COMMENT ON SCHEMA neodb IS 'Neobiology Database';
GRANT ALL ON SCHEMA neodb TO :user;
GRANT USAGE ON SCHEMA neodb TO :user;

CREATE TABLE neodb.collection_types (
	id SERIAL PRIMARY KEY NOT NULL,
	collection_type VARCHAR(50) NOT NULL,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.collection_types IS 'types of collections - taxonomic';
GRANT ALL ON TABLE neodb.collection_types TO :user;

CREATE TABLE neodb.geom_bases (
	id SERIAL PRIMARY KEY NOT NULL,
	geom_basis VARCHAR(50) NOT NULL,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.geom_bases IS 'basis for the coordinates entered for collection location';
GRANT ALL ON TABLE neodb.geom_bases TO :user;


CREATE TABLE neodb.baits (
	id SERIAL PRIMARY KEY NOT NULL,
	bait VARCHAR(50) /* the bait or attractant used to collect specimens */,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.baits IS 'bait used to attract specimens for observation or collection';
GRANT ALL ON TABLE neodb.baits TO :user;


CREATE TABLE neodb.collection_media (
	id SERIAL PRIMARY KEY NOT NULL,
	collection_medium VARCHAR(50) /* medium from which specimens were collected: sand, leaf litter, mud etc. */,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.collection_media IS 'medium upon or within which specimens were observed or collected';
GRANT ALL ON TABLE neodb.collection_media TO :user;


CREATE TABLE neodb.taxa (
	id SERIAL PRIMARY KEY NOT NULL,
	taxon_name VARCHAR(100) NOT NULL,
	taxon_author VARCHAR(100) NOT NULL DEFAULT '',
	common_name VARCHAR(100) NOT NULL DEFAULT '',
	taxon_order VARCHAR(50) NOT NULL DEFAULT '',
	taxon_family VARCHAR(50) NOT NULL DEFAULT '',
	taxon_genus VARCHAR(50) NOT NULL DEFAULT '',
	taxon_subgenus VARCHAR(50) NOT NULL DEFAULT '',
	taxon_species VARCHAR(50) NOT NULL DEFAULT '',
	taxon_subspecies VARCHAR(50) NOT NULL DEFAULT '',
	taxon_rank VARCHAR(100) NOT NULL DEFAULT '',
	pbdb_taxon_no INTEGER,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
	);
COMMENT ON TABLE neodb.taxa IS 'this is a temporary table of taxonomic nomenclature to be replaced eventually with the PaleoDB''s taxonomy tables.';
GRANT ALL ON TABLE neodb.taxa TO :user;


CREATE TABLE neodb.roles (
	id SERIAL PRIMARY KEY NOT NULL,
	role VARCHAR(50) NOT NULL,
	authorizations VARCHAR(100),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.roles IS 'user, member, data enterer, administrator etc.';
GRANT ALL ON TABLE neodb.roles TO :user;


CREATE TABLE neodb.environments (
	id SERIAL PRIMARY KEY NOT NULL,
	environ VARCHAR(100) NOT NULL,
	environ_type VARCHAR(50) NOT NULL,
	environ_class VARCHAR(50) NOT NULL,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
GRANT ALL ON TABLE neodb.environments TO :user;


CREATE TABLE neodb.institutions (
	id SERIAL PRIMARY KEY NOT NULL,
	institution_name VARCHAR(100) NOT NULL,
	institution_abbrev VARCHAR(10),
	country VARCHAR(100),
	url VARCHAR(100),
	is_repository BOOLEAN NOT NULL DEFAULT FALSE, 
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	geom_basis_id INTEGER
);
SELECT AddGeometryColumn ('neodb','institutions','the_geom',4326,'POINT',2); /* coordinates of the repository location */
COMMENT ON TABLE neodb.institutions IS 'collections/places/museums etc. where collected occurrences are stored or where individuals are affiliated';
COMMENT ON COLUMN neodb.institutions.the_geom IS 'coordinates of the repository location';
GRANT ALL ON TABLE neodb.institutions TO :user;

CREATE TABLE neodb.images (
	id SERIAL PRIMARY KEY NOT NULL,
	photographer_id INTEGER NOT NULL,
	full_file VARCHAR(50) NOT NULL,
	main_file VARCHAR(50) NOT NULL,
	thumb_file VARCHAR(50) NOT NULL,
	description TEXT /* short caption or description of the photograph  */,
	image_date DATE NOT NULL /* day photograph was taken */,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	geom_basis_id INTEGER
);
SELECT AddGeometryColumn ('neodb','images','the_geom',4326,'POINT',2); /* coordinates for where the photograph was taken */
COMMENT ON TABLE neodb.images IS 'image files for occurrences';
COMMENT ON COLUMN neodb.images.description IS 'short caption or description of the photograph ';
COMMENT ON COLUMN neodb.images.image_date IS 'day photograph was taken';
COMMENT ON COLUMN neodb.images.the_geom IS 'coordinates for where the photograph was taken';
GRANT ALL ON TABLE neodb.images TO :user;


CREATE TABLE neodb.notes (
	id SERIAL PRIMARY KEY NOT NULL,
	note TEXT NOT NULL,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
GRANT ALL ON TABLE neodb.notes TO :user;


CREATE TABLE neodb.collection_methods (
	id SERIAL PRIMARY KEY NOT NULL,
	collection_method VARCHAR(100) NOT NULL,
	collection_type_id INTEGER NOT NULL REFERENCES neodb.collection_types (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.collection_methods IS 'methods or devices used to collect specimens';
GRANT ALL ON TABLE neodb.collection_methods TO :user;

CREATE TABLE neodb.people (
	id SERIAL PRIMARY KEY NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	initials VARCHAR (10),
	last_name VARCHAR(50) NOT NULL,
	expertise VARCHAR(50) /* beetles, birds, etc */,
	title VARCHAR(50) /* amateur, curatior, engineer, etc */,
	institution_id INTEGER REFERENCES neodb.institutions (id),
	email VARCHAR(50),
	username VARCHAR(50),
	password VARCHAR(72),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	geom_basis_id INTEGER
);
SELECT AddGeometryColumn ('neodb','people','the_geom',4326,'POINT',2); /* optional coordinate of where the person lives or works */
COMMENT ON TABLE neodb.people IS 'people involved in data collection and entry';
COMMENT ON COLUMN neodb.people.expertise IS 'beetles, birds, etc';
COMMENT ON COLUMN neodb.people.title IS 'amateur, curatior, engineer, etc';
COMMENT ON COLUMN neodb.people.the_geom IS 'optional coordinate of where the person lives or works';
GRANT ALL ON TABLE neodb.people TO :user;

CREATE TABLE neodb.occurrences (
	id SERIAL PRIMARY KEY NOT NULL,
	family_taxon_name VARCHAR(50), /*the highest allowable taxonomic resolution*/
	taxon_id INTEGER REFERENCES neodb.taxa (id), /*taxon_id of occurrences*/
	taxon_name VARCHAR(100) NOT NULL, /*occurrence's taxon name*/
	taxon_author VARCHAR(50), /*author of occurrences taxon*/
	common_name VARCHAR(100) NOT NULL, /*occurrence's common name*/
	collection_date_start DATE NOT NULL,
	collection_date_end DATE,
	method_id INTEGER REFERENCES neodb.collection_methods (id),
	bait_id INTEGER REFERENCES neodb.baits (id),
	medium_id INTEGER REFERENCES neodb.collection_media (id),
	type_id INTEGER,
	only_observed BOOLEAN NOT NULL,
	country VARCHAR(50),
	state VARCHAR(50),
	county VARCHAR(50),
	city VARCHAR(75),
	address VARCHAR(100),
	location_note VARCHAR(150),
	repository_id INTEGER REFERENCES neodb.institutions (id),
	n_total_specimens INTEGER /* this is the total number of voucher specimens - entered here or calculated from n_male and n_female */,
	n_male_specimens INTEGER,
	n_female_specimens INTEGER,
	enterer_id INTEGER NOT NULL REFERENCES neodb.people (id),
	note_id INTEGER REFERENCES neodb.notes (id),
	geom_basis_id INTEGER,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
SELECT AddGeometryColumn ('neodb','occurrences','the_geom',4326,'POINT',2);
COMMENT ON TABLE neodb.occurrences IS 'occurrences which include beetle series, bird sightings, etc.';
COMMENT ON COLUMN neodb.occurrences.n_total_specimens IS 'this is the total number of voucher specimens - entered here or calculated from n_male and n_female';
GRANT ALL ON TABLE neodb.occurrences TO :user;


CREATE TABLE neodb.associated_taxa (
	id SERIAL PRIMARY KEY NOT NULL,
	occurrence_id INTEGER NOT NULL REFERENCES neodb.occurrences (id)/* primary taxon */,
	taxon_id INTEGER NOT NULL REFERENCES neodb.taxa (id)/* the taxon_id of the taxon or host associated with the primary occurrence */,
	occurrence_host BOOLEAN NOT NULL /* T=the occurrence was found on and/or collected from this associated taxon */,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.associated_taxa IS 'table for host and/or associated taxa that occurrences were found with';
COMMENT ON COLUMN neodb.associated_taxa.occurrence_id IS 'primary taxon';
COMMENT ON COLUMN neodb.associated_taxa.taxon_id IS 'the taxon_id of the taxon or host associated with the primary occurrence';
COMMENT ON COLUMN neodb.associated_taxa.occurrence_host IS 'T=the occurrence was found on and/or collected from this associated taxon';
GRANT ALL ON TABLE neodb.associated_taxa TO :user;


CREATE TABLE neodb.taxa_images (
	id SERIAL PRIMARY KEY NOT NULL,
	image_id INTEGER NOT NULL REFERENCES neodb.images (id),
	taxon_id INTEGER NOT NULL REFERENCES neodb.taxa (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.taxa_images IS 'images that are of particular taxa in the database but not of specific occurrences';
GRANT ALL ON TABLE neodb.taxa_images TO :user;


CREATE TABLE neodb.occurrences_images (
	id SERIAL PRIMARY KEY NOT NULL,
	image_id INTEGER NOT NULL REFERENCES neodb.images (id),
	occurrence_id INTEGER NOT NULL REFERENCES neodb.occurrences (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
GRANT ALL ON TABLE neodb.occurrences_images TO :user;


CREATE TABLE neodb.environments_images (
	id SERIAL PRIMARY KEY NOT NULL,
	image_id INTEGER NOT NULL REFERENCES neodb.images (id),
	environment_id INTEGER NOT NULL REFERENCES neodb.environments (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.environments_images IS 'images of environmental settings';
GRANT ALL ON TABLE neodb.environments_images TO :user;


CREATE TABLE neodb.people_roles (
	id SERIAL PRIMARY KEY NOT NULL,
	person_id INTEGER NOT NULL REFERENCES neodb.people (id),
	role_id INTEGER NOT NULL REFERENCES neodb.roles (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
GRANT ALL ON TABLE neodb.people_roles TO :user;


CREATE TABLE neodb.opinions (
	id SERIAL PRIMARY KEY NOT NULL,
	occurrence_id INTEGER NOT NULL REFERENCES neodb.occurrences (id),
	taxon_id INTEGER NOT NULL REFERENCES neodb.taxa (id),
	determiner_id INTEGER NOT NULL REFERENCES neodb.people (id),
	determination_date DATE NOT NULL,
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
COMMENT ON TABLE neodb.opinions IS 'this table stores opinions about which occurrences should be assigned to which taxa';
GRANT ALL ON TABLE neodb.opinions TO :user;


CREATE TABLE neodb.occurrences_environments (
	id SERIAL PRIMARY KEY NOT NULL,
	occurrence_id INTEGER NOT NULL REFERENCES neodb.occurrences (id),
	environment_id INTEGER NOT NULL REFERENCES neodb.environments (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
GRANT ALL ON TABLE neodb.occurrences_environments TO :user;


CREATE TABLE neodb.occurrences_collectors (
	id SERIAL PRIMARY KEY NOT NULL,
	occurrence_id INTEGER NOT NULL REFERENCES neodb.occurrences (id),
	collector_id INTEGER NOT NULL REFERENCES neodb.people (id),
	created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
	modified_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
);
GRANT ALL ON TABLE neodb.occurrences_collectors TO :user;

-- Alterations to the schema to acount for paleodb ids
ALTER TABLE neodb.taxa ADD COLUMN pbdb_family_no integer;
ALTER TABLE neodb.taxa ADD COLUMN pbdb_genus_no integer;
ALTER TABLE neodb.taxa ADD COLUMN pbdb_species_no integer;
ALTER TABLE neodb.taxa ADD COLUMN pbdb_subspecies_no integer;

ALTER TABLE neodb.occurrences DROP COLUMN taxon_author;
ALTER TABLE neodb.occurrences DROP COLUMN family_taxon_name;
ALTER TABLE neodb.occurrences DROP COLUMN taxon_name;
ALTER TABLE neodb.occurrences DROP COLUMN common_name;
