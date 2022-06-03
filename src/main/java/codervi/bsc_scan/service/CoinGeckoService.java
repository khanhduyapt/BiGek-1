package codervi.bsc_scan.service;

import java.util.List;

import codervi.bsc_scan.entity.CandidateCoin;
import codervi.bsc_scan.request.CoinGeckoTokenRequest;
import codervi.bsc_scan.utils.Response;

public interface CoinGeckoService {

    public Response add(CoinGeckoTokenRequest request);

    public Response delete(CoinGeckoTokenRequest request);

    public List<CandidateCoin> initCandidateCoin();

    public List<CandidateCoin> getList();

    public CandidateCoin loadData(String gecko_id);
}
