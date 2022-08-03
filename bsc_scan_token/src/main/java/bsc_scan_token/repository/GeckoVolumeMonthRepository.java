package bsc_scan_token.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_token.entity.GeckoVolumeMonth;
import bsc_scan_token.entity.GeckoVolumeMonthKey;

@Repository
public interface GeckoVolumeMonthRepository extends JpaRepository<GeckoVolumeMonth, GeckoVolumeMonthKey> {

}
