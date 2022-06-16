package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.PriorityCoinHistory;

@Repository
public interface PriorityCoinHistoryRepository extends JpaRepository<PriorityCoinHistory, String> {

}
