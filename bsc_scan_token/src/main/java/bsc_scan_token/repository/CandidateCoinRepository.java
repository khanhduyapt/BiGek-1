package bsc_scan_token.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import bsc_scan_token.entity.CandidateCoin;

@Repository
public interface CandidateCoinRepository extends JpaRepository<CandidateCoin, String> {

    @Query(value = "SELECT m.* FROM all_market_candidate_coin m WHERE visible and coingecko_rank is null ORDER BY gecko_id", nativeQuery = true)
    public List<CandidateCoin> findCandidateCoinInBinanceFutures();

}
