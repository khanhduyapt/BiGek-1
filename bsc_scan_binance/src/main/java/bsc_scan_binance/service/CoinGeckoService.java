package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.request.CoinGeckoTokenRequest;
import bsc_scan_binance.utils.Response;

public interface CoinGeckoService {

	public Response add(CoinGeckoTokenRequest request);

	public Response delete(CoinGeckoTokenRequest request);

	public Response note(CoinGeckoTokenRequest request);

	public Response priority(CoinGeckoTokenRequest request);

	public List<CandidateCoin> initCandidateCoin();

	public List<CandidateCoin> getList(String formBinance);

	public CandidateCoin loadData(String gecko_id);

	public void delete(String gecko_id);
}
