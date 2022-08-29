package bsc_scan_btc_futures.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_btc_futures.entity.DepthAsks;
import bsc_scan_btc_futures.entity.DepthKey;

@Repository
public interface DepthAsksRepository extends JpaRepository<DepthAsks, DepthKey> {

}
