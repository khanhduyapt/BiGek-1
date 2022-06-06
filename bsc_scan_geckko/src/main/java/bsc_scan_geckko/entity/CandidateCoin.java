package bsc_scan_geckko.entity;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "candidate_coin")

public class CandidateCoin {
	@Id
	@Column(name = "gecko_id")
	private String geckoid;

	@Column(name = "symbol")
	private String symbol;

	@Column(name = "name")
	private String name;

	@Column(name = "category")
	private String category;

	@Column(name = "trend")
	private String trend;

	@Column(name = "usdt")
	private String usdt;

	@Column(name = "busd")
	private String busd;

	@Column(name = "total_supply")
	private BigDecimal totalSupply;

	@Column(name = "max_supply")
	private BigDecimal maxSupply;

	@Column(name = "circulating_supply")
	private BigDecimal circulatingSupply;

	@Column(name = "binance_trade")
	private String binanceTrade;

	@Column(name = "coin_gecko_link")
	private String coinGeckoLink;

	@Column(name = "backer")
	private String backer;

	@Column(name = "market_cap")
	private BigDecimal marketCap;

	@Column(name = "current_price")
	private BigDecimal currentPrice;

	@Column(name = "total_volume")
	private BigDecimal totalVolume;

	@Column(name = "price_change_percentage_24h")
	private BigDecimal priceChangePercentage24H;

	@Column(name = "price_change_percentage_7d")
	private BigDecimal priceChangePercentage7D;

	@Column(name = "price_change_percentage_14d")
	private BigDecimal priceChangePercentage14D;

	@Column(name = "price_change_percentage_30d")
	private BigDecimal priceChangePercentage30D;

	@Column(name = "volumn_div_marketcap")
	private BigDecimal volumnDivMarketcap;

	public CandidateCoin(String geckoid, String symbol, String name) {
		this.geckoid = geckoid;
		this.symbol = symbol;
		this.name = name;
	}

}
