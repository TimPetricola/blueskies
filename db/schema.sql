--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: fn_link_last_curated_at(); Type: FUNCTION; Schema: public; Owner: Tim
--

CREATE FUNCTION fn_link_last_curated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          UPDATE links SET last_curated_at = CURRENT_TIMESTAMP WHERE id = NEW.link_id;
          RETURN NEW;
        END;
      $$;


ALTER FUNCTION public.fn_link_last_curated_at() OWNER TO "Tim";

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: curators; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE curators (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    facebook_identifier text NOT NULL,
    last_curated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE curators OWNER TO "Tim";

--
-- Name: curators_links; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE curators_links (
    curator_id uuid NOT NULL,
    link_id uuid NOT NULL
);


ALTER TABLE curators_links OWNER TO "Tim";

--
-- Name: digests; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE digests (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    recipient_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE digests OWNER TO "Tim";

--
-- Name: digests_links; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE digests_links (
    digest_id uuid NOT NULL,
    link_id uuid NOT NULL
);


ALTER TABLE digests_links OWNER TO "Tim";

--
-- Name: interests; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE interests (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    stems text[] DEFAULT '{}'::text[],
    published boolean DEFAULT false NOT NULL
);


ALTER TABLE interests OWNER TO "Tim";

--
-- Name: interests_links; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE interests_links (
    interest_id uuid NOT NULL,
    link_id uuid NOT NULL
);


ALTER TABLE interests_links OWNER TO "Tim";

--
-- Name: interests_recipients; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE interests_recipients (
    interest_id uuid NOT NULL,
    recipient_id uuid NOT NULL
);


ALTER TABLE interests_recipients OWNER TO "Tim";

--
-- Name: links; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE links (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    url text NOT NULL,
    title text,
    description text,
    extracted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_curated_at timestamp without time zone,
    share_count bigint,
    image hstore
);


ALTER TABLE links OWNER TO "Tim";

--
-- Name: recipients; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE recipients (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    schedule text,
    next_digest_job_id text,
    token text NOT NULL
);


ALTER TABLE recipients OWNER TO "Tim";

--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: Tim; Tablespace: 
--

CREATE TABLE schema_info (
    version integer DEFAULT 0 NOT NULL
);


ALTER TABLE schema_info OWNER TO "Tim";

--
-- Name: curators_links_pk; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY curators_links
    ADD CONSTRAINT curators_links_pk PRIMARY KEY (curator_id, link_id);


--
-- Name: curators_pkey; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY curators
    ADD CONSTRAINT curators_pkey PRIMARY KEY (id);


--
-- Name: digests_links_pk; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY digests_links
    ADD CONSTRAINT digests_links_pk PRIMARY KEY (digest_id, link_id);


--
-- Name: digests_pkey; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY digests
    ADD CONSTRAINT digests_pkey PRIMARY KEY (id);


--
-- Name: interests_links_pk; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY interests_links
    ADD CONSTRAINT interests_links_pk PRIMARY KEY (interest_id, link_id);


--
-- Name: interests_name_key; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY interests
    ADD CONSTRAINT interests_name_key UNIQUE (name);


--
-- Name: interests_pkey; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY interests
    ADD CONSTRAINT interests_pkey PRIMARY KEY (id);


--
-- Name: interests_recipients_pk; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY interests_recipients
    ADD CONSTRAINT interests_recipients_pk PRIMARY KEY (interest_id, recipient_id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: links_url_key; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_url_key UNIQUE (url);


--
-- Name: recipients_email_key; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY recipients
    ADD CONSTRAINT recipients_email_key UNIQUE (email);


--
-- Name: recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY recipients
    ADD CONSTRAINT recipients_pkey PRIMARY KEY (id);


--
-- Name: recipients_token_key; Type: CONSTRAINT; Schema: public; Owner: Tim; Tablespace: 
--

ALTER TABLE ONLY recipients
    ADD CONSTRAINT recipients_token_key UNIQUE (token);


--
-- Name: curators_links_curator_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX curators_links_curator_id_index ON curators_links USING btree (curator_id);


--
-- Name: curators_links_link_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX curators_links_link_id_index ON curators_links USING btree (link_id);


--
-- Name: digests_links_digest_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX digests_links_digest_id_index ON digests_links USING btree (digest_id);


--
-- Name: digests_links_link_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX digests_links_link_id_index ON digests_links USING btree (link_id);


--
-- Name: digests_recipient_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX digests_recipient_id_index ON digests USING btree (recipient_id);


--
-- Name: interests_links_interest_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX interests_links_interest_id_index ON interests_links USING btree (interest_id);


--
-- Name: interests_links_link_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX interests_links_link_id_index ON interests_links USING btree (link_id);


--
-- Name: interests_recipients_interest_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX interests_recipients_interest_id_index ON interests_recipients USING btree (interest_id);


--
-- Name: interests_recipients_recipient_id_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX interests_recipients_recipient_id_index ON interests_recipients USING btree (recipient_id);


--
-- Name: interests_stems_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX interests_stems_index ON interests USING gin (stems);


--
-- Name: links_url_index; Type: INDEX; Schema: public; Owner: Tim; Tablespace: 
--

CREATE INDEX links_url_index ON links USING btree (url);


--
-- Name: trg_link_last_curated_at; Type: TRIGGER; Schema: public; Owner: Tim
--

CREATE TRIGGER trg_link_last_curated_at AFTER INSERT ON curators_links FOR EACH ROW EXECUTE PROCEDURE fn_link_last_curated_at();


--
-- Name: curators_links_curator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY curators_links
    ADD CONSTRAINT curators_links_curator_id_fkey FOREIGN KEY (curator_id) REFERENCES curators(id) ON DELETE CASCADE;


--
-- Name: curators_links_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY curators_links
    ADD CONSTRAINT curators_links_link_id_fkey FOREIGN KEY (link_id) REFERENCES links(id) ON DELETE CASCADE;


--
-- Name: digests_links_digest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY digests_links
    ADD CONSTRAINT digests_links_digest_id_fkey FOREIGN KEY (digest_id) REFERENCES digests(id) ON DELETE CASCADE;


--
-- Name: digests_links_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY digests_links
    ADD CONSTRAINT digests_links_link_id_fkey FOREIGN KEY (link_id) REFERENCES links(id) ON DELETE CASCADE;


--
-- Name: digests_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY digests
    ADD CONSTRAINT digests_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES recipients(id) ON DELETE CASCADE;


--
-- Name: interests_links_interest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY interests_links
    ADD CONSTRAINT interests_links_interest_id_fkey FOREIGN KEY (interest_id) REFERENCES interests(id) ON DELETE CASCADE;


--
-- Name: interests_links_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY interests_links
    ADD CONSTRAINT interests_links_link_id_fkey FOREIGN KEY (link_id) REFERENCES links(id) ON DELETE CASCADE;


--
-- Name: interests_recipients_interest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY interests_recipients
    ADD CONSTRAINT interests_recipients_interest_id_fkey FOREIGN KEY (interest_id) REFERENCES interests(id) ON DELETE CASCADE;


--
-- Name: interests_recipients_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: Tim
--

ALTER TABLE ONLY interests_recipients
    ADD CONSTRAINT interests_recipients_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES recipients(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: Tim
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM "Tim";
GRANT ALL ON SCHEMA public TO "Tim";
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

