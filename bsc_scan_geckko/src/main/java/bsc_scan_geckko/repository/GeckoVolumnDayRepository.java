package bsc_scan_geckko.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_geckko.entity.GeckoVolumnDay;
import bsc_scan_geckko.entity.GeckoVolumnDayKey;

@Repository
public interface GeckoVolumnDayRepository extends JpaRepository<GeckoVolumnDay, GeckoVolumnDayKey> {

}
