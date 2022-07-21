package bsc_scan_geckko.service;

import java.util.List;

import bsc_scan_geckko.entity.CandidateCoin;

public interface CoinGeckoService {
	public List<CandidateCoin> initCandidateCoin();

	public List<CandidateCoin> getList();

	public CandidateCoin loadData(String gecko_id);

	public void delete(String gecko_id);
}
