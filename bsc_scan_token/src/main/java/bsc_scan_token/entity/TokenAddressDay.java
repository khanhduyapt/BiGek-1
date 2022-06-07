package bsc_scan_token.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "token_address_day")

//CREATE TABLE IF NOT EXISTS public.token_address_day
//(
//    gecko_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
//    address character varying(225) COLLATE pg_catalog."default" NOT NULL,
//    dd character varying(2) COLLATE pg_catalog."default" NOT NULL,
//    quantity numeric(30,0) NOT NULL,
//    alias character varying(225) COLLATE pg_catalog."default" DEFAULT NULL::character varying,
//    CONSTRAINT token_address_day_pkey PRIMARY KEY (gecko_id, address, dd)
//);

public class TokenAddressDay {
    @EmbeddedId
    private TokenAddressDayKey id;

    @Column(name = "quantity")
    private BigDecimal quantity;

    @Column(name = "alias")
    private String alias;
}
