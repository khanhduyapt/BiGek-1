package bsc_scan_btc_futures.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_btc_futures.entity.BtcFutures;

@Repository
public interface BtcFuturesRepository extends JpaRepository<BtcFutures, String> {

}
