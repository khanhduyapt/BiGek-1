package bsc_scan_binance.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_binance.entity.GeckoVolumeUpPre4h;

@Repository
public interface GeckoVolumeUpPre4hRepository extends JpaRepository<GeckoVolumeUpPre4h, String> {

}
