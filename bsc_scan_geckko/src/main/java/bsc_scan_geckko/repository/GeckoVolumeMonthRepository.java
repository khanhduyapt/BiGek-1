package bsc_scan_geckko.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_geckko.entity.GeckoVolumeMonth;
import bsc_scan_geckko.entity.GeckoVolumeMonthKey;

@Repository
public interface GeckoVolumeMonthRepository extends JpaRepository<GeckoVolumeMonth, GeckoVolumeMonthKey> {

}
