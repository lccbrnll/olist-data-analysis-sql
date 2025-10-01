-- =================================================================
--          TABLE CREATION SCRIPT FOR THE OLIST E-COMMERCE PROJECT
-- =================================================================

-- Table: category_name_translation
-- Description: A lookup table that maps product category names from Portuguese to English.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.category_name_translation
(
    product_category_name character varying(100) COLLATE pg_catalog."default",
    product_category_name_english character varying(100) COLLATE pg_catalog."default"
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.category_name_translation
    OWNER to postgres;


-- Table: customers
-- Description: Contains identification and location data for each customer who has made a purchase.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.customers
(
    customer_id character varying(50) COLLATE pg_catalog."default" NOT NULL,
    customer_unique_id character varying(50) COLLATE pg_catalog."default",
    customer_zip_code_prefix character varying(10) COLLATE pg_catalog."default",
    customer_city character varying(100) COLLATE pg_catalog."default",
    customer_state character varying(2) COLLATE pg_catalog."default",
    CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.customers
    OWNER to postgres;


-- Table: geolocation
-- Description: A reference table that maps Brazilian zip code prefixes to geographic coordinates (latitude and longitude).
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.geolocation
(
    geolocation_zip_code_prefix character varying(10) COLLATE pg_catalog."default",
    geolocation_lat numeric(10,8),
    geolocation_lng numeric(11,8),
    geolocation_city character varying(100) COLLATE pg_catalog."default",
    geolocation_state character varying(2) COLLATE pg_catalog."default"
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.geolocation
    OWNER to postgres;


-- Table: order_items
-- Description: A junction table that details the specific items within each order. It connects an order to one or more products and sellers.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.order_items
(
    order_id character varying(50) COLLATE pg_catalog."default",
    order_item_id integer,
    product_id character varying(50) COLLATE pg_catalog."default",
    seller_id character varying(50) COLLATE pg_catalog."default",
    shipping_limit_date timestamp without time zone,
    price numeric(10,2),
    freight_value numeric(10,2)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.order_items
    OWNER to postgres;


-- Table: order_payments
-- Description: Records the payment information associated with each order. A single order can have multiple payment methods.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.order_payments
(
    order_id character varying(50) COLLATE pg_catalog."default",
    payment_sequential integer,
    payment_type character varying(25) COLLATE pg_catalog."default",
    payment_installments integer,
    payment_value numeric(10,2)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.order_payments
    OWNER to postgres;


-- Table: order_reviews
-- Description: Stores customer reviews (scores and comments) for each order, crucial for satisfaction analysis.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.order_reviews
(
    review_id character varying(50) COLLATE pg_catalog."default",
    order_id character varying(50) COLLATE pg_catalog."default",
    review_score smallint,
    review_comment_title text COLLATE pg_catalog."default",
    review_comment_message text COLLATE pg_catalog."default",
    review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.order_reviews
    OWNER to postgres;


-- Table: orders
-- Description: The central table in the data model, containing information about each order placed, its status, associated customer, and relevant timestamps.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.orders
(
    order_id character varying(50) COLLATE pg_catalog."default" NOT NULL,
    customer_id character varying(50) COLLATE pg_catalog."default",
    order_status character varying(25) COLLATE pg_catalog."default",
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone,
    CONSTRAINT olist_orders_pkey PRIMARY KEY (order_id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.orders
    OWNER to postgres;


-- Table: products
-- Description: Acts as the product catalog, containing information about each unique item, such as its category and physical dimensions (weight, size).
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.products
(
    product_id character varying(50) COLLATE pg_catalog."default",
    product_category_name character varying(100) COLLATE pg_catalog."default",
    product_name_lenght smallint,
    product_description_lenght smallint,
    product_photos_qty smallint,
    product_weight_g integer,
    product_length_cm smallint,
    product_height_cm smallint,
    product_width_cm smallint
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.products
    OWNER to postgres;


-- Table: sellers
-- Description: Contains registration data for each seller who uses the Olist platform, including their location.
-- -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.sellers
(
    seller_id character varying(50) COLLATE pg_catalog."default",
    seller_zip_code_prefix character varying(10) COLLATE pg_catalog."default",
    seller_city character varying(100) COLLATE pg_catalog."default",
    seller_state character varying(2) COLLATE pg_catalog."default"
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sellers
    OWNER to postgres;
