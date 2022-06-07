package bsc_scan_token.service;

public interface TokenService {

//	public Response add(CoinGeckoTokenRequest request);
//
//	public Response delete(CoinGeckoTokenRequest request);
//
//	public Response note(CoinGeckoTokenRequest request);
//
//	public Response priority(CoinGeckoTokenRequest request);
//
//	public List<CandidateCoin> initCandidateCoin();
//
//	public List<CandidateCoin> getList();
//
    public void loadBscData(String blockchain, String contract_address, String gecko_id, Integer page);
}
