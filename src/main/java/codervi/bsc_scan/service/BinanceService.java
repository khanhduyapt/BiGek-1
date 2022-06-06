package codervi.bsc_scan.service;

import java.util.List;

import codervi.bsc_scan.response.CandidateTokenCssResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList();

    public void loadData(String gecko_id, String symbol);

}
