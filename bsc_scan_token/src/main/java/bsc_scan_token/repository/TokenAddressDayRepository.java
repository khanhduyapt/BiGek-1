package bsc_scan_token.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_token.entity.TokenAddressDay;
import bsc_scan_token.entity.TokenAddressDayKey;

@Repository
public interface TokenAddressDayRepository extends JpaRepository<TokenAddressDay, TokenAddressDayKey> {

}
