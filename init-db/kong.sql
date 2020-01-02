--
-- PostgreSQL database dump
--

-- Dumped from database version 10.0
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: sync_tags(); Type: FUNCTION; Schema: public; Owner: kong
--

CREATE FUNCTION sync_tags() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF (TG_OP = 'TRUNCATE') THEN
            DELETE FROM tags WHERE entity_name = TG_TABLE_NAME;
            RETURN NULL;
          ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM tags WHERE entity_id = OLD.id;
            RETURN OLD;
          ELSE

          -- Triggered by INSERT/UPDATE
          -- Do an upsert on the tags table
          -- So we don't need to migrate pre 1.1 entities
          INSERT INTO tags VALUES (NEW.id, TG_TABLE_NAME, NEW.tags)
          ON CONFLICT (entity_id) DO UPDATE
                  SET tags=EXCLUDED.tags;
          END IF;
          RETURN NEW;
        END;
      $$;


ALTER FUNCTION public.sync_tags() OWNER TO kong;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acls; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE acls (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    "group" text,
    cache_key text,
    tags text[]
);


ALTER TABLE acls OWNER TO kong;

--
-- Name: apis; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE apis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(3)),
    name text,
    upstream_url text,
    preserve_host boolean NOT NULL,
    retries smallint DEFAULT 5,
    https_only boolean,
    http_if_terminated boolean,
    hosts text,
    uris text,
    methods text,
    strip_uri boolean,
    upstream_connect_timeout integer,
    upstream_send_timeout integer,
    upstream_read_timeout integer
);


ALTER TABLE apis OWNER TO kong;

--
-- Name: basicauth_credentials; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE basicauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    username text,
    password text,
    tags text[]
);


ALTER TABLE basicauth_credentials OWNER TO kong;

--
-- Name: ca_certificates; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE ca_certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    cert text NOT NULL,
    tags text[]
);


ALTER TABLE ca_certificates OWNER TO kong;

--
-- Name: certificates; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    cert text,
    key text,
    tags text[]
);


ALTER TABLE certificates OWNER TO kong;

--
-- Name: cluster_ca; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE cluster_ca (
    pk boolean NOT NULL,
    key text NOT NULL,
    cert text NOT NULL,
    CONSTRAINT cluster_ca_pk_check CHECK ((pk = true))
);


ALTER TABLE cluster_ca OWNER TO kong;

--
-- Name: cluster_events; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE cluster_events (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    at timestamp with time zone NOT NULL,
    nbf timestamp with time zone,
    expire_at timestamp with time zone NOT NULL,
    channel text,
    data text
);


ALTER TABLE cluster_events OWNER TO kong;

--
-- Name: consumers; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE consumers (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    username text,
    custom_id text,
    tags text[]
);


ALTER TABLE consumers OWNER TO kong;

--
-- Name: hmacauth_credentials; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE hmacauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    username text,
    secret text,
    tags text[]
);


ALTER TABLE hmacauth_credentials OWNER TO kong;

--
-- Name: jwt_secrets; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE jwt_secrets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    key text,
    secret text,
    algorithm text,
    rsa_public_key text,
    tags text[]
);


ALTER TABLE jwt_secrets OWNER TO kong;

--
-- Name: keyauth_credentials; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE keyauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    consumer_id uuid,
    key text,
    tags text[],
    ttl timestamp with time zone
);


ALTER TABLE keyauth_credentials OWNER TO kong;

--
-- Name: konga_api_health_checks; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_api_health_checks (
    id integer NOT NULL,
    api_id text,
    api json,
    health_check_endpoint text,
    notification_endpoint text,
    active boolean,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_api_health_checks OWNER TO kong;

--
-- Name: konga_api_health_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_api_health_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_api_health_checks_id_seq OWNER TO kong;

--
-- Name: konga_api_health_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_api_health_checks_id_seq OWNED BY konga_api_health_checks.id;


--
-- Name: konga_email_transports; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_email_transports (
    id integer NOT NULL,
    name text,
    description text,
    schema json,
    settings json,
    active boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_email_transports OWNER TO kong;

--
-- Name: konga_email_transports_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_email_transports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_email_transports_id_seq OWNER TO kong;

--
-- Name: konga_email_transports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_email_transports_id_seq OWNED BY konga_email_transports.id;


--
-- Name: konga_kong_nodes; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_kong_nodes (
    id integer NOT NULL,
    name text,
    type text,
    kong_admin_url text,
    netdata_url text,
    kong_api_key text,
    jwt_algorithm text,
    jwt_key text,
    jwt_secret text,
    kong_version text,
    health_checks boolean,
    health_check_details json,
    active boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_kong_nodes OWNER TO kong;

--
-- Name: konga_kong_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_kong_nodes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_kong_nodes_id_seq OWNER TO kong;

--
-- Name: konga_kong_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_kong_nodes_id_seq OWNED BY konga_kong_nodes.id;


--
-- Name: konga_kong_services; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_kong_services (
    id integer NOT NULL,
    service_id text,
    kong_node_id text,
    description text,
    tags json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_kong_services OWNER TO kong;

--
-- Name: konga_kong_services_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_kong_services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_kong_services_id_seq OWNER TO kong;

--
-- Name: konga_kong_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_kong_services_id_seq OWNED BY konga_kong_services.id;


--
-- Name: konga_kong_snapshot_schedules; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_kong_snapshot_schedules (
    id integer NOT NULL,
    connection integer,
    active boolean,
    cron text,
    "lastRunAt" date,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_kong_snapshot_schedules OWNER TO kong;

--
-- Name: konga_kong_snapshot_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_kong_snapshot_schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_kong_snapshot_schedules_id_seq OWNER TO kong;

--
-- Name: konga_kong_snapshot_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_kong_snapshot_schedules_id_seq OWNED BY konga_kong_snapshot_schedules.id;


--
-- Name: konga_kong_snapshots; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_kong_snapshots (
    id integer NOT NULL,
    name text,
    kong_node_name text,
    kong_node_url text,
    kong_version text,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_kong_snapshots OWNER TO kong;

--
-- Name: konga_kong_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_kong_snapshots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_kong_snapshots_id_seq OWNER TO kong;

--
-- Name: konga_kong_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_kong_snapshots_id_seq OWNED BY konga_kong_snapshots.id;


--
-- Name: konga_kong_upstream_alerts; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_kong_upstream_alerts (
    id integer NOT NULL,
    upstream_id text,
    connection integer,
    email boolean,
    slack boolean,
    cron text,
    active boolean,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_kong_upstream_alerts OWNER TO kong;

--
-- Name: konga_kong_upstream_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_kong_upstream_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_kong_upstream_alerts_id_seq OWNER TO kong;

--
-- Name: konga_kong_upstream_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_kong_upstream_alerts_id_seq OWNED BY konga_kong_upstream_alerts.id;


--
-- Name: konga_netdata_connections; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_netdata_connections (
    id integer NOT NULL,
    "apiId" text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_netdata_connections OWNER TO kong;

--
-- Name: konga_netdata_connections_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_netdata_connections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_netdata_connections_id_seq OWNER TO kong;

--
-- Name: konga_netdata_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_netdata_connections_id_seq OWNED BY konga_netdata_connections.id;


--
-- Name: konga_passports; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_passports (
    id integer NOT NULL,
    protocol text,
    password text,
    provider text,
    identifier text,
    tokens json,
    "user" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE konga_passports OWNER TO kong;

--
-- Name: konga_passports_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_passports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_passports_id_seq OWNER TO kong;

--
-- Name: konga_passports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_passports_id_seq OWNED BY konga_passports.id;


--
-- Name: konga_settings; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_settings (
    id integer NOT NULL,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_settings OWNER TO kong;

--
-- Name: konga_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_settings_id_seq OWNER TO kong;

--
-- Name: konga_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_settings_id_seq OWNED BY konga_settings.id;


--
-- Name: konga_users; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE konga_users (
    id integer NOT NULL,
    username text,
    email text,
    "firstName" text,
    "lastName" text,
    admin boolean,
    node_id text,
    active boolean,
    "activationToken" text,
    node integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE konga_users OWNER TO kong;

--
-- Name: konga_users_id_seq; Type: SEQUENCE; Schema: public; Owner: kong
--

CREATE SEQUENCE konga_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konga_users_id_seq OWNER TO kong;

--
-- Name: konga_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kong
--

ALTER SEQUENCE konga_users_id_seq OWNED BY konga_users.id;


--
-- Name: locks; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE locks (
    key text NOT NULL,
    owner text,
    ttl timestamp with time zone
);


ALTER TABLE locks OWNER TO kong;

--
-- Name: oauth2_authorization_codes; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE oauth2_authorization_codes (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    credential_id uuid,
    service_id uuid,
    code text,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone
);


ALTER TABLE oauth2_authorization_codes OWNER TO kong;

--
-- Name: oauth2_credentials; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE oauth2_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text,
    consumer_id uuid,
    client_id text,
    client_secret text,
    redirect_uris text[],
    tags text[]
);


ALTER TABLE oauth2_credentials OWNER TO kong;

--
-- Name: oauth2_tokens; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE oauth2_tokens (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    credential_id uuid,
    service_id uuid,
    access_token text,
    refresh_token text,
    token_type text,
    expires_in integer,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone
);


ALTER TABLE oauth2_tokens OWNER TO kong;

--
-- Name: plugins; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE plugins (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text NOT NULL,
    consumer_id uuid,
    service_id uuid,
    route_id uuid,
    api_id uuid,
    config jsonb NOT NULL,
    enabled boolean NOT NULL,
    cache_key text,
    run_on text,
    protocols text[],
    tags text[]
);


ALTER TABLE plugins OWNER TO kong;

--
-- Name: ratelimiting_metrics; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer
);


ALTER TABLE ratelimiting_metrics OWNER TO kong;

--
-- Name: response_ratelimiting_metrics; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE response_ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer
);


ALTER TABLE response_ratelimiting_metrics OWNER TO kong;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE routes (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    service_id uuid,
    protocols text[],
    methods text[],
    hosts text[],
    paths text[],
    regex_priority bigint,
    strip_path boolean,
    preserve_host boolean,
    name text,
    snis text[],
    sources jsonb[],
    destinations jsonb[],
    tags text[],
    https_redirect_status_code integer,
    headers jsonb
);


ALTER TABLE routes OWNER TO kong;

--
-- Name: schema_meta; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE schema_meta (
    key text NOT NULL,
    subsystem text NOT NULL,
    last_executed text,
    executed text[],
    pending text[]
);


ALTER TABLE schema_meta OWNER TO kong;

--
-- Name: services; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE services (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name text,
    retries bigint,
    protocol text,
    host text,
    port bigint,
    path text,
    connect_timeout bigint,
    write_timeout bigint,
    read_timeout bigint,
    tags text[],
    client_certificate_id uuid
);


ALTER TABLE services OWNER TO kong;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE sessions (
    id uuid NOT NULL,
    session_id text,
    expires integer,
    data text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE sessions OWNER TO kong;

--
-- Name: snis; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE snis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(0)),
    name text NOT NULL,
    certificate_id uuid,
    tags text[]
);


ALTER TABLE snis OWNER TO kong;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE tags (
    entity_id uuid NOT NULL,
    entity_name text,
    tags text[]
);


ALTER TABLE tags OWNER TO kong;

--
-- Name: targets; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE targets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(3)),
    upstream_id uuid,
    target text NOT NULL,
    weight integer NOT NULL,
    tags text[]
);


ALTER TABLE targets OWNER TO kong;

--
-- Name: ttls; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE ttls (
    primary_key_value text NOT NULL,
    primary_uuid_value uuid,
    table_name text NOT NULL,
    primary_key_name text NOT NULL,
    expire_at timestamp without time zone NOT NULL
);


ALTER TABLE ttls OWNER TO kong;

--
-- Name: upstreams; Type: TABLE; Schema: public; Owner: kong
--

CREATE TABLE upstreams (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, CURRENT_TIMESTAMP(3)),
    name text,
    hash_on text,
    hash_fallback text,
    hash_on_header text,
    hash_fallback_header text,
    hash_on_cookie text,
    hash_on_cookie_path text,
    slots integer NOT NULL,
    healthchecks jsonb,
    host_header text,
    tags text[],
    algorithm text
);


ALTER TABLE upstreams OWNER TO kong;

--
-- Name: konga_api_health_checks id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_api_health_checks ALTER COLUMN id SET DEFAULT nextval('konga_api_health_checks_id_seq'::regclass);


--
-- Name: konga_email_transports id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_email_transports ALTER COLUMN id SET DEFAULT nextval('konga_email_transports_id_seq'::regclass);


--
-- Name: konga_kong_nodes id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_nodes ALTER COLUMN id SET DEFAULT nextval('konga_kong_nodes_id_seq'::regclass);


--
-- Name: konga_kong_services id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_services ALTER COLUMN id SET DEFAULT nextval('konga_kong_services_id_seq'::regclass);


--
-- Name: konga_kong_snapshot_schedules id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_snapshot_schedules ALTER COLUMN id SET DEFAULT nextval('konga_kong_snapshot_schedules_id_seq'::regclass);


--
-- Name: konga_kong_snapshots id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_snapshots ALTER COLUMN id SET DEFAULT nextval('konga_kong_snapshots_id_seq'::regclass);


--
-- Name: konga_kong_upstream_alerts id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_upstream_alerts ALTER COLUMN id SET DEFAULT nextval('konga_kong_upstream_alerts_id_seq'::regclass);


--
-- Name: konga_netdata_connections id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_netdata_connections ALTER COLUMN id SET DEFAULT nextval('konga_netdata_connections_id_seq'::regclass);


--
-- Name: konga_passports id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_passports ALTER COLUMN id SET DEFAULT nextval('konga_passports_id_seq'::regclass);


--
-- Name: konga_settings id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_settings ALTER COLUMN id SET DEFAULT nextval('konga_settings_id_seq'::regclass);


--
-- Name: konga_users id; Type: DEFAULT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_users ALTER COLUMN id SET DEFAULT nextval('konga_users_id_seq'::regclass);


--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY acls (id, created_at, consumer_id, "group", cache_key, tags) FROM stdin;
\.


--
-- Data for Name: apis; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY apis (id, created_at, name, upstream_url, preserve_host, retries, https_only, http_if_terminated, hosts, uris, methods, strip_uri, upstream_connect_timeout, upstream_send_timeout, upstream_read_timeout) FROM stdin;
\.


--
-- Data for Name: basicauth_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY basicauth_credentials (id, created_at, consumer_id, username, password, tags) FROM stdin;
\.


--
-- Data for Name: ca_certificates; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY ca_certificates (id, created_at, cert, tags) FROM stdin;
\.


--
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY certificates (id, created_at, cert, key, tags) FROM stdin;
\.


--
-- Data for Name: cluster_ca; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY cluster_ca (pk, key, cert) FROM stdin;
\.


--
-- Data for Name: cluster_events; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY cluster_events (id, node_id, at, nbf, expire_at, channel, data) FROM stdin;
\.


--
-- Data for Name: consumers; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY consumers (id, created_at, username, custom_id, tags) FROM stdin;
\.


--
-- Data for Name: hmacauth_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY hmacauth_credentials (id, created_at, consumer_id, username, secret, tags) FROM stdin;
\.


--
-- Data for Name: jwt_secrets; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY jwt_secrets (id, created_at, consumer_id, key, secret, algorithm, rsa_public_key, tags) FROM stdin;
\.


--
-- Data for Name: keyauth_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY keyauth_credentials (id, created_at, consumer_id, key, tags, ttl) FROM stdin;
\.


--
-- Data for Name: konga_api_health_checks; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_api_health_checks (id, api_id, api, health_check_endpoint, notification_endpoint, active, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Data for Name: konga_email_transports; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_email_transports (id, name, description, schema, settings, active, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	smtp	Send emails using the SMTP protocol	[{"name":"host","description":"The SMTP host","type":"text","required":true},{"name":"port","description":"The SMTP port","type":"text","required":true},{"name":"username","model":"auth.user","description":"The SMTP user username","type":"text","required":true},{"name":"password","model":"auth.pass","description":"The SMTP user password","type":"text","required":true},{"name":"secure","model":"secure","description":"Use secure connection","type":"boolean"}]	{"host":"","port":"","auth":{"user":"","pass":""},"secure":false}	t	2020-01-02 06:59:46+00	2020-01-02 07:15:13+00	\N	\N
2	sendmail	Pipe messages to the sendmail command	\N	{"sendmail":true}	f	2020-01-02 06:59:46+00	2020-01-02 07:15:13+00	\N	\N
3	mailgun	Send emails through Mailgun’s Web API	[{"name":"api_key","model":"auth.api_key","description":"The API key that you got from www.mailgun.com/cp","type":"text","required":true},{"name":"domain","model":"auth.domain","description":"One of your domain names listed at your https://mailgun.com/app/domains","type":"text","required":true}]	{"auth":{"api_key":"","domain":""}}	f	2020-01-02 06:59:46+00	2020-01-02 07:15:13+00	\N	\N
\.


--
-- Data for Name: konga_kong_nodes; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_kong_nodes (id, name, type, kong_admin_url, netdata_url, kong_api_key, jwt_algorithm, jwt_key, jwt_secret, kong_version, health_checks, health_check_details, active, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	docker	default	http://kong:8001	\N		HS256	\N	\N	1.4.2	f	\N	f	2020-01-02 07:16:02+00	2020-01-02 07:16:03+00	1	1
\.


--
-- Data for Name: konga_kong_services; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_kong_services (id, service_id, kong_node_id, description, tags, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Data for Name: konga_kong_snapshot_schedules; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_kong_snapshot_schedules (id, connection, active, cron, "lastRunAt", "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Data for Name: konga_kong_snapshots; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_kong_snapshots (id, name, kong_node_name, kong_node_url, kong_version, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Data for Name: konga_kong_upstream_alerts; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_kong_upstream_alerts (id, upstream_id, connection, email, slack, cron, active, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Data for Name: konga_netdata_connections; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_netdata_connections (id, "apiId", url, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Data for Name: konga_passports; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_passports (id, protocol, password, provider, identifier, tokens, "user", "createdAt", "updatedAt") FROM stdin;
1	local	$2a$10$w.08uZQN4kIHkxSvdZOzQuqP9Rg50dP/cD4mfsnJmUePCkXQdp5Wy	\N	\N	\N	1	2020-01-02 07:15:43+00	2020-01-02 07:15:43+00
\.


--
-- Data for Name: konga_settings; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_settings (id, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	{"signup_enable":false,"signup_require_activation":false,"info_polling_interval":5000,"email_default_sender_name":"KONGA","email_default_sender":"konga@konga.test","email_notifications":false,"default_transport":"sendmail","notify_when":{"node_down":{"title":"A node is down or unresponsive","description":"Health checks must be enabled for the nodes that need to be monitored.","active":false},"api_down":{"title":"An API is down or unresponsive","description":"Health checks must be enabled for the APIs that need to be monitored.","active":false}},"integrations":[{"id":"slack","name":"Slack","image":"slack_rgb.png","config":{"enabled":false,"fields":[{"id":"slack_webhook_url","name":"Slack Webhook URL","type":"text","required":true,"value":""}],"slack_webhook_url":""}}],"user_permissions":{"apis":{"create":false,"read":true,"update":false,"delete":false},"services":{"create":false,"read":true,"update":false,"delete":false},"routes":{"create":false,"read":true,"update":false,"delete":false},"consumers":{"create":false,"read":true,"update":false,"delete":false},"plugins":{"create":false,"read":true,"update":false,"delete":false},"upstreams":{"create":false,"read":true,"update":false,"delete":false},"certificates":{"create":false,"read":true,"update":false,"delete":false},"connections":{"create":false,"read":true,"update":false,"delete":false},"users":{"create":false,"read":true,"update":false,"delete":false}}}	2020-01-02 06:59:46+00	2020-01-02 07:15:13+00	\N	\N
\.


--
-- Data for Name: konga_users; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY konga_users (id, username, email, "firstName", "lastName", admin, node_id, active, "activationToken", node, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	admin	admin@admin.com	\N	\N	t		t	58777823-7c49-42c2-a125-725a0982e79e	1	2020-01-02 07:15:42+00	2020-01-02 07:16:03+00	\N	1
\.


--
-- Data for Name: locks; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY locks (key, owner, ttl) FROM stdin;
\.


--
-- Data for Name: oauth2_authorization_codes; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY oauth2_authorization_codes (id, created_at, credential_id, service_id, code, authenticated_userid, scope, ttl) FROM stdin;
\.


--
-- Data for Name: oauth2_credentials; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY oauth2_credentials (id, created_at, name, consumer_id, client_id, client_secret, redirect_uris, tags) FROM stdin;
\.


--
-- Data for Name: oauth2_tokens; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY oauth2_tokens (id, created_at, credential_id, service_id, access_token, refresh_token, token_type, expires_in, authenticated_userid, scope, ttl) FROM stdin;
\.


--
-- Data for Name: plugins; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY plugins (id, created_at, name, consumer_id, service_id, route_id, api_id, config, enabled, cache_key, run_on, protocols, tags) FROM stdin;
\.


--
-- Data for Name: ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value) FROM stdin;
\.


--
-- Data for Name: response_ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY response_ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value) FROM stdin;
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY routes (id, created_at, updated_at, service_id, protocols, methods, hosts, paths, regex_priority, strip_path, preserve_host, name, snis, sources, destinations, tags, https_redirect_status_code, headers) FROM stdin;
\.


--
-- Data for Name: schema_meta; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY schema_meta (key, subsystem, last_executed, executed, pending) FROM stdin;
schema_meta	core	006_130_to_140	{000_base,001_14_to_15,002_15_to_1,003_100_to_110,004_110_to_120,005_120_to_130,006_130_to_140}	{}
schema_meta	hmac-auth	002_130_to_140	{000_base_hmac_auth,001_14_to_15,002_130_to_140}	\N
schema_meta	oauth2	003_130_to_140	{000_base_oauth2,001_14_to_15,002_15_to_10,003_130_to_140}	{}
schema_meta	jwt	002_130_to_140	{000_base_jwt,001_14_to_15,002_130_to_140}	\N
schema_meta	basic-auth	002_130_to_140	{000_base_basic_auth,001_14_to_15,002_130_to_140}	\N
schema_meta	key-auth	002_130_to_140	{000_base_key_auth,001_14_to_15,002_130_to_140}	\N
schema_meta	rate-limiting	003_10_to_112	{000_base_rate_limiting,001_14_to_15,002_15_to_10,003_10_to_112}	{}
schema_meta	acl	002_130_to_140	{000_base_acl,001_14_to_15,002_130_to_140}	{}
schema_meta	response-ratelimiting	002_15_to_10	{000_base_response_rate_limiting,001_14_to_15,002_15_to_10}	{}
schema_meta	session	000_base_session	{000_base_session}	\N
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY services (id, created_at, updated_at, name, retries, protocol, host, port, path, connect_timeout, write_timeout, read_timeout, tags, client_certificate_id) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY sessions (id, session_id, expires, data, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: snis; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY snis (id, created_at, name, certificate_id, tags) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY tags (entity_id, entity_name, tags) FROM stdin;
\.


--
-- Data for Name: targets; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY targets (id, created_at, upstream_id, target, weight, tags) FROM stdin;
\.


--
-- Data for Name: ttls; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY ttls (primary_key_value, primary_uuid_value, table_name, primary_key_name, expire_at) FROM stdin;
\.


--
-- Data for Name: upstreams; Type: TABLE DATA; Schema: public; Owner: kong
--

COPY upstreams (id, created_at, name, hash_on, hash_fallback, hash_on_header, hash_fallback_header, hash_on_cookie, hash_on_cookie_path, slots, healthchecks, host_header, tags, algorithm) FROM stdin;
\.


--
-- Name: konga_api_health_checks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_api_health_checks_id_seq', 1, false);


--
-- Name: konga_email_transports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_email_transports_id_seq', 3, true);


--
-- Name: konga_kong_nodes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_kong_nodes_id_seq', 1, true);


--
-- Name: konga_kong_services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_kong_services_id_seq', 1, false);


--
-- Name: konga_kong_snapshot_schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_kong_snapshot_schedules_id_seq', 1, false);


--
-- Name: konga_kong_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_kong_snapshots_id_seq', 1, false);


--
-- Name: konga_kong_upstream_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_kong_upstream_alerts_id_seq', 1, false);


--
-- Name: konga_netdata_connections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_netdata_connections_id_seq', 1, false);


--
-- Name: konga_passports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_passports_id_seq', 1, true);


--
-- Name: konga_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_settings_id_seq', 1, true);


--
-- Name: konga_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kong
--

SELECT pg_catalog.setval('konga_users_id_seq', 1, true);


--
-- Name: acls acls_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_cache_key_key UNIQUE (cache_key);


--
-- Name: acls acls_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);


--
-- Name: apis apis_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY apis
    ADD CONSTRAINT apis_name_key UNIQUE (name);


--
-- Name: apis apis_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY apis
    ADD CONSTRAINT apis_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_username_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_username_key UNIQUE (username);


--
-- Name: ca_certificates ca_certificates_cert_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY ca_certificates
    ADD CONSTRAINT ca_certificates_cert_key UNIQUE (cert);


--
-- Name: ca_certificates ca_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY ca_certificates
    ADD CONSTRAINT ca_certificates_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: cluster_ca cluster_ca_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY cluster_ca
    ADD CONSTRAINT cluster_ca_pkey PRIMARY KEY (pk);


--
-- Name: cluster_events cluster_events_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY cluster_events
    ADD CONSTRAINT cluster_events_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_custom_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY consumers
    ADD CONSTRAINT consumers_custom_id_key UNIQUE (custom_id);


--
-- Name: consumers consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY consumers
    ADD CONSTRAINT consumers_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_username_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY consumers
    ADD CONSTRAINT consumers_username_key UNIQUE (username);


--
-- Name: hmacauth_credentials hmacauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials hmacauth_credentials_username_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_username_key UNIQUE (username);


--
-- Name: jwt_secrets jwt_secrets_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY jwt_secrets
    ADD CONSTRAINT jwt_secrets_key_key UNIQUE (key);


--
-- Name: jwt_secrets jwt_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY jwt_secrets
    ADD CONSTRAINT jwt_secrets_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials keyauth_credentials_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_key_key UNIQUE (key);


--
-- Name: keyauth_credentials keyauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: konga_api_health_checks konga_api_health_checks_api_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_api_health_checks
    ADD CONSTRAINT konga_api_health_checks_api_id_key UNIQUE (api_id);


--
-- Name: konga_api_health_checks konga_api_health_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_api_health_checks
    ADD CONSTRAINT konga_api_health_checks_pkey PRIMARY KEY (id);


--
-- Name: konga_email_transports konga_email_transports_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_email_transports
    ADD CONSTRAINT konga_email_transports_name_key UNIQUE (name);


--
-- Name: konga_email_transports konga_email_transports_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_email_transports
    ADD CONSTRAINT konga_email_transports_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_nodes konga_kong_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_nodes
    ADD CONSTRAINT konga_kong_nodes_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_services konga_kong_services_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_services
    ADD CONSTRAINT konga_kong_services_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_services konga_kong_services_service_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_services
    ADD CONSTRAINT konga_kong_services_service_id_key UNIQUE (service_id);


--
-- Name: konga_kong_snapshot_schedules konga_kong_snapshot_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_snapshot_schedules
    ADD CONSTRAINT konga_kong_snapshot_schedules_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_snapshots konga_kong_snapshots_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_snapshots
    ADD CONSTRAINT konga_kong_snapshots_name_key UNIQUE (name);


--
-- Name: konga_kong_snapshots konga_kong_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_snapshots
    ADD CONSTRAINT konga_kong_snapshots_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_upstream_alerts konga_kong_upstream_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_upstream_alerts
    ADD CONSTRAINT konga_kong_upstream_alerts_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_upstream_alerts konga_kong_upstream_alerts_upstream_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_kong_upstream_alerts
    ADD CONSTRAINT konga_kong_upstream_alerts_upstream_id_key UNIQUE (upstream_id);


--
-- Name: konga_netdata_connections konga_netdata_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_netdata_connections
    ADD CONSTRAINT konga_netdata_connections_pkey PRIMARY KEY (id);


--
-- Name: konga_passports konga_passports_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_passports
    ADD CONSTRAINT konga_passports_pkey PRIMARY KEY (id);


--
-- Name: konga_settings konga_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_settings
    ADD CONSTRAINT konga_settings_pkey PRIMARY KEY (id);


--
-- Name: konga_users konga_users_email_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_users
    ADD CONSTRAINT konga_users_email_key UNIQUE (email);


--
-- Name: konga_users konga_users_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_users
    ADD CONSTRAINT konga_users_pkey PRIMARY KEY (id);


--
-- Name: konga_users konga_users_username_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY konga_users
    ADD CONSTRAINT konga_users_username_key UNIQUE (username);


--
-- Name: locks locks_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY locks
    ADD CONSTRAINT locks_pkey PRIMARY KEY (key);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_code_key UNIQUE (code);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth2_credentials oauth2_credentials_client_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_client_id_key UNIQUE (client_id);


--
-- Name: oauth2_credentials oauth2_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_pkey PRIMARY KEY (id);


--
-- Name: oauth2_tokens oauth2_tokens_access_token_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_access_token_key UNIQUE (access_token);


--
-- Name: oauth2_tokens oauth2_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth2_tokens oauth2_tokens_refresh_token_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_refresh_token_key UNIQUE (refresh_token);


--
-- Name: plugins plugins_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY plugins
    ADD CONSTRAINT plugins_cache_key_key UNIQUE (cache_key);


--
-- Name: plugins plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: ratelimiting_metrics ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY ratelimiting_metrics
    ADD CONSTRAINT ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: response_ratelimiting_metrics response_ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY response_ratelimiting_metrics
    ADD CONSTRAINT response_ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: routes routes_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_name_key UNIQUE (name);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: schema_meta schema_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY schema_meta
    ADD CONSTRAINT schema_meta_pkey PRIMARY KEY (key, subsystem);


--
-- Name: services services_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_name_key UNIQUE (name);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: snis snis_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY snis
    ADD CONSTRAINT snis_name_key UNIQUE (name);


--
-- Name: snis snis_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY snis
    ADD CONSTRAINT snis_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (entity_id);


--
-- Name: targets targets_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: ttls ttls_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY ttls
    ADD CONSTRAINT ttls_pkey PRIMARY KEY (primary_key_value, table_name);


--
-- Name: upstreams upstreams_name_key; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY upstreams
    ADD CONSTRAINT upstreams_name_key UNIQUE (name);


--
-- Name: upstreams upstreams_pkey; Type: CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY upstreams
    ADD CONSTRAINT upstreams_pkey PRIMARY KEY (id);


--
-- Name: acls_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX acls_consumer_id_idx ON acls USING btree (consumer_id);


--
-- Name: acls_group_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX acls_group_idx ON acls USING btree ("group");


--
-- Name: acls_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX acls_tags_idex_tags_idx ON acls USING gin (tags);


--
-- Name: basicauth_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX basicauth_consumer_id_idx ON basicauth_credentials USING btree (consumer_id);


--
-- Name: basicauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX basicauth_tags_idex_tags_idx ON basicauth_credentials USING gin (tags);


--
-- Name: certificates_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX certificates_tags_idx ON certificates USING gin (tags);


--
-- Name: cluster_events_at_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX cluster_events_at_idx ON cluster_events USING btree (at);


--
-- Name: cluster_events_channel_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX cluster_events_channel_idx ON cluster_events USING btree (channel);


--
-- Name: cluster_events_expire_at_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX cluster_events_expire_at_idx ON cluster_events USING btree (expire_at);


--
-- Name: consumers_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX consumers_tags_idx ON consumers USING gin (tags);


--
-- Name: consumers_username_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX consumers_username_idx ON consumers USING btree (lower(username));


--
-- Name: hmacauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX hmacauth_credentials_consumer_id_idx ON hmacauth_credentials USING btree (consumer_id);


--
-- Name: hmacauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX hmacauth_tags_idex_tags_idx ON hmacauth_credentials USING gin (tags);


--
-- Name: jwt_secrets_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX jwt_secrets_consumer_id_idx ON jwt_secrets USING btree (consumer_id);


--
-- Name: jwt_secrets_secret_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX jwt_secrets_secret_idx ON jwt_secrets USING btree (secret);


--
-- Name: jwtsecrets_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX jwtsecrets_tags_idex_tags_idx ON jwt_secrets USING gin (tags);


--
-- Name: keyauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX keyauth_credentials_consumer_id_idx ON keyauth_credentials USING btree (consumer_id);


--
-- Name: keyauth_credentials_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX keyauth_credentials_ttl_idx ON keyauth_credentials USING btree (ttl);


--
-- Name: keyauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX keyauth_tags_idex_tags_idx ON keyauth_credentials USING gin (tags);


--
-- Name: locks_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX locks_ttl_idx ON locks USING btree (ttl);


--
-- Name: oauth2_authorization_codes_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_codes_authenticated_userid_idx ON oauth2_authorization_codes USING btree (authenticated_userid);


--
-- Name: oauth2_authorization_codes_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_codes_ttl_idx ON oauth2_authorization_codes USING btree (ttl);


--
-- Name: oauth2_authorization_credential_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_credential_id_idx ON oauth2_authorization_codes USING btree (credential_id);


--
-- Name: oauth2_authorization_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_authorization_service_id_idx ON oauth2_authorization_codes USING btree (service_id);


--
-- Name: oauth2_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_credentials_consumer_id_idx ON oauth2_credentials USING btree (consumer_id);


--
-- Name: oauth2_credentials_secret_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_credentials_secret_idx ON oauth2_credentials USING btree (client_secret);


--
-- Name: oauth2_credentials_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_credentials_tags_idex_tags_idx ON oauth2_credentials USING gin (tags);


--
-- Name: oauth2_tokens_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_authenticated_userid_idx ON oauth2_tokens USING btree (authenticated_userid);


--
-- Name: oauth2_tokens_credential_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_credential_id_idx ON oauth2_tokens USING btree (credential_id);


--
-- Name: oauth2_tokens_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_service_id_idx ON oauth2_tokens USING btree (service_id);


--
-- Name: oauth2_tokens_ttl_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX oauth2_tokens_ttl_idx ON oauth2_tokens USING btree (ttl);


--
-- Name: plugins_api_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_api_id_idx ON plugins USING btree (api_id);


--
-- Name: plugins_consumer_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_consumer_id_idx ON plugins USING btree (consumer_id);


--
-- Name: plugins_name_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_name_idx ON plugins USING btree (name);


--
-- Name: plugins_route_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_route_id_idx ON plugins USING btree (route_id);


--
-- Name: plugins_run_on_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_run_on_idx ON plugins USING btree (run_on);


--
-- Name: plugins_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_service_id_idx ON plugins USING btree (service_id);


--
-- Name: plugins_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX plugins_tags_idx ON plugins USING gin (tags);


--
-- Name: ratelimiting_metrics_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX ratelimiting_metrics_idx ON ratelimiting_metrics USING btree (service_id, route_id, period_date, period);


--
-- Name: routes_service_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX routes_service_id_idx ON routes USING btree (service_id);


--
-- Name: routes_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX routes_tags_idx ON routes USING gin (tags);


--
-- Name: services_fkey_client_certificate; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX services_fkey_client_certificate ON services USING btree (client_certificate_id);


--
-- Name: services_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX services_tags_idx ON services USING gin (tags);


--
-- Name: session_sessions_expires_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX session_sessions_expires_idx ON sessions USING btree (expires);


--
-- Name: snis_certificate_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX snis_certificate_id_idx ON snis USING btree (certificate_id);


--
-- Name: snis_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX snis_tags_idx ON snis USING gin (tags);


--
-- Name: tags_entity_name_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX tags_entity_name_idx ON tags USING btree (entity_name);


--
-- Name: tags_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX tags_tags_idx ON tags USING gin (tags);


--
-- Name: targets_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX targets_tags_idx ON targets USING gin (tags);


--
-- Name: targets_target_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX targets_target_idx ON targets USING btree (target);


--
-- Name: targets_upstream_id_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX targets_upstream_id_idx ON targets USING btree (upstream_id);


--
-- Name: ttls_primary_uuid_value_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX ttls_primary_uuid_value_idx ON ttls USING btree (primary_uuid_value);


--
-- Name: upstreams_tags_idx; Type: INDEX; Schema: public; Owner: kong
--

CREATE INDEX upstreams_tags_idx ON upstreams USING gin (tags);


--
-- Name: acls acls_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER acls_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON acls FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: basicauth_credentials basicauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER basicauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON basicauth_credentials FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: ca_certificates ca_certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER ca_certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON ca_certificates FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: certificates certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON certificates FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: consumers consumers_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER consumers_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON consumers FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: hmacauth_credentials hmacauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER hmacauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON hmacauth_credentials FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: jwt_secrets jwtsecrets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER jwtsecrets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON jwt_secrets FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: keyauth_credentials keyauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER keyauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON keyauth_credentials FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: oauth2_credentials oauth2_credentials_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER oauth2_credentials_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON oauth2_credentials FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: plugins plugins_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER plugins_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON plugins FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: routes routes_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER routes_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON routes FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: services services_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER services_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON services FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: snis snis_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER snis_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON snis FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: targets targets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER targets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON targets FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: upstreams upstreams_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: kong
--

CREATE TRIGGER upstreams_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON upstreams FOR EACH ROW EXECUTE PROCEDURE sync_tags();


--
-- Name: acls acls_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: basicauth_credentials basicauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials hmacauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: jwt_secrets jwt_secrets_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY jwt_secrets
    ADD CONSTRAINT jwt_secrets_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: keyauth_credentials keyauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES oauth2_credentials(id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_service_id_fkey FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;


--
-- Name: oauth2_credentials oauth2_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES oauth2_credentials(id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_service_id_fkey FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;


--
-- Name: plugins plugins_api_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY plugins
    ADD CONSTRAINT plugins_api_id_fkey FOREIGN KEY (api_id) REFERENCES apis(id) ON DELETE CASCADE;


--
-- Name: plugins plugins_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY plugins
    ADD CONSTRAINT plugins_consumer_id_fkey FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE;


--
-- Name: plugins plugins_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY plugins
    ADD CONSTRAINT plugins_route_id_fkey FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE;


--
-- Name: plugins plugins_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY plugins
    ADD CONSTRAINT plugins_service_id_fkey FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;


--
-- Name: routes routes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_service_id_fkey FOREIGN KEY (service_id) REFERENCES services(id);


--
-- Name: services services_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_client_certificate_id_fkey FOREIGN KEY (client_certificate_id) REFERENCES certificates(id);


--
-- Name: snis snis_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY snis
    ADD CONSTRAINT snis_certificate_id_fkey FOREIGN KEY (certificate_id) REFERENCES certificates(id);


--
-- Name: targets targets_upstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kong
--

ALTER TABLE ONLY targets
    ADD CONSTRAINT targets_upstream_id_fkey FOREIGN KEY (upstream_id) REFERENCES upstreams(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO kong;


--
-- PostgreSQL database dump complete
--

