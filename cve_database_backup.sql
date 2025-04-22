--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1+b1)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1+b1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    company_id integer NOT NULL,
    name character varying(100) NOT NULL,
    domain character varying(100) NOT NULL
);


ALTER TABLE public.company OWNER TO postgres;

--
-- Name: company_company_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.company_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.company_company_id_seq OWNER TO postgres;

--
-- Name: company_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.company_company_id_seq OWNED BY public.company.company_id;


--
-- Name: cve; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cve (
    cve_id integer NOT NULL,
    name character varying(255) NOT NULL,
    first_seen date NOT NULL,
    update_date date,
    published date NOT NULL,
    description text NOT NULL,
    required_action text,
    cvss_vector character varying(255),
    exploitability_score numeric(3,1),
    impact_score numeric(3,1),
    cvss_score numeric(3,1) NOT NULL,
    status character varying(10) NOT NULL,
    user_id integer,
    system_version character varying(50),
    system_id integer,
    company_id integer,
    CONSTRAINT cve_status_check CHECK (((status)::text = ANY ((ARRAY['solved'::character varying, 'not solved'::character varying])::text[])))
);


ALTER TABLE public.cve OWNER TO postgres;

--
-- Name: cve_cve_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cve_cve_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cve_cve_id_seq OWNER TO postgres;

--
-- Name: cve_cve_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cve_cve_id_seq OWNED BY public.cve.cve_id;


--
-- Name: system; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system (
    system_id integer NOT NULL,
    system_version character varying(50),
    product_name character varying(100) NOT NULL,
    version character varying(50) NOT NULL
);


ALTER TABLE public.system OWNER TO postgres;

--
-- Name: system_system_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_system_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_system_id_seq OWNER TO postgres;

--
-- Name: system_system_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_system_id_seq OWNED BY public.system.system_id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    user_id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    mail character varying(100) NOT NULL,
    birthday date,
    capacity character varying(50),
    system_id integer,
    company_id integer,
    password character varying(100) NOT NULL
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_user_id_seq OWNER TO postgres;

--
-- Name: user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_user_id_seq OWNED BY public."user".user_id;


--
-- Name: company company_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company ALTER COLUMN company_id SET DEFAULT nextval('public.company_company_id_seq'::regclass);


--
-- Name: cve cve_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve ALTER COLUMN cve_id SET DEFAULT nextval('public.cve_cve_id_seq'::regclass);


--
-- Name: system system_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system ALTER COLUMN system_id SET DEFAULT nextval('public.system_system_id_seq'::regclass);


--
-- Name: user user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN user_id SET DEFAULT nextval('public.user_user_id_seq'::regclass);


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company (company_id, name, domain) FROM stdin;
1	CyberSecure	cybersecure.com
\.


--
-- Data for Name: cve; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cve (cve_id, name, first_seen, update_date, published, description, required_action, cvss_vector, exploitability_score, impact_score, cvss_score, status, user_id, system_version, system_id, company_id) FROM stdin;
1	CVE-2024-12345	2024-03-10	2024-03-20	2024-03-15	Podatność w XYZ	Zaktualizować oprogramowanie	AV:N/AC:L/Au:N/C:C/I:C/A:C	9.8	8.5	9.8	not solved	1	\N	1	1
\.


--
-- Data for Name: system; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system (system_id, system_version, product_name, version) FROM stdin;
1	10.0.17763	Windows Server	2019
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (user_id, name, surname, mail, birthday, capacity, system_id, company_id, password) FROM stdin;
1	Jan	Kowalski	jan.kowalski@cybersecure.com	1990-05-15	Security Analyst	1	1    $2b$12$WqT7eSzElrYxgR/qZkMLOexSOquEX9JWaA8OABd7CWezEfHk9EDru
\.


--
-- Name: company_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.company_company_id_seq', 1, true);


--
-- Name: cve_cve_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cve_cve_id_seq', 1, true);


--
-- Name: system_system_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_system_id_seq', 1, true);


--
-- Name: user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_user_id_seq', 1, true);


--
-- Name: company company_domain_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_domain_key UNIQUE (domain);


--
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (company_id);


--
-- Name: cve cve_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve
    ADD CONSTRAINT cve_pkey PRIMARY KEY (cve_id);


--
-- Name: system system_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system
    ADD CONSTRAINT system_pkey PRIMARY KEY (system_id);


--
-- Name: user user_mail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_mail_key UNIQUE (mail);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- Name: cve cve_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve
    ADD CONSTRAINT cve_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.company(company_id);


--
-- Name: cve cve_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve
    ADD CONSTRAINT cve_system_id_fkey FOREIGN KEY (system_id) REFERENCES public.system(system_id);


--
-- Name: cve cve_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve
    ADD CONSTRAINT cve_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(user_id);


--
-- Name: user user_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.company(company_id);


--
-- Name: user user_system_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_system_id_fkey FOREIGN KEY (system_id) REFERENCES public.system(system_id);


--
-- PostgreSQL database dump complete
--

