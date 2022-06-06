package codervi.bsc_scan.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import codervi.bsc_scan.entity.CandidateCoin;

@Repository
public interface CandidateCoinRepository extends JpaRepository<CandidateCoin, String> {
    public List<CandidateCoin> findAllByOrderByVolumnDivMarketcapDesc();
}
