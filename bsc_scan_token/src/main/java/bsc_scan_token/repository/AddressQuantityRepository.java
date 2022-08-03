package bsc_scan_token.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import bsc_scan_token.entity.AddressQuantity;
import bsc_scan_token.entity.AddressQuantityKey;

@Repository
public interface AddressQuantityRepository extends JpaRepository<AddressQuantity, AddressQuantityKey> {

}
