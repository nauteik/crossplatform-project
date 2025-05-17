package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Address;
import com.example.ecommerceproject.repository.AddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class AddressService {

    private final AddressRepository addressRepository;

    @Autowired
    public AddressService(AddressRepository addressRepository) {
        this.addressRepository = addressRepository;
    }

    /**
     * Thêm địa chỉ mới cho người dùng
     */
    public Address addAddress(String userId, Address address) {
        address.setId(UUID.randomUUID().toString());
        address.setUserId(userId);
        
        // Nếu đây là địa chỉ mặc định hoặc người dùng chưa có địa chỉ nào
        if (address.isDefault() || addressRepository.findByUserId(userId).isEmpty()) {
            // Đảm bảo chỉ có một địa chỉ mặc định
            resetDefaultAddresses(userId);
            address.setDefault(true);
        }
        
        return addressRepository.save(address);
    }

    /**
     * Cập nhật địa chỉ của người dùng
     */
    public Address updateAddress(String userId, String addressId, Address updatedAddress) {
        Address existingAddress = getAddressByIdAndUserId(addressId, userId);
        
        // Cập nhật các trường của địa chỉ
        existingAddress.setFullName(updatedAddress.getFullName());
        existingAddress.setPhoneNumber(updatedAddress.getPhoneNumber());
        existingAddress.setAddressLine(updatedAddress.getAddressLine());
        existingAddress.setCity(updatedAddress.getCity());
        existingAddress.setDistrict(updatedAddress.getDistrict());
        existingAddress.setWard(updatedAddress.getWard());
        
        // Nếu cập nhật thành địa chỉ mặc định
        if (updatedAddress.isDefault() && !existingAddress.isDefault()) {
            resetDefaultAddresses(userId);
            existingAddress.setDefault(true);
        }
        
        return addressRepository.save(existingAddress);
    }

    /**
     * Xóa địa chỉ của người dùng
     */
    @Transactional
    public void deleteAddress(String userId, String addressId) {
        Address address = getAddressByIdAndUserId(addressId, userId);
        
        addressRepository.delete(address);
        
        // Nếu đã xóa địa chỉ mặc định và còn địa chỉ khác, đặt địa chỉ đầu tiên làm mặc định
        if (address.isDefault()) {
            List<Address> remainingAddresses = addressRepository.findByUserId(userId);
            if (!remainingAddresses.isEmpty()) {
                Address firstAddress = remainingAddresses.get(0);
                firstAddress.setDefault(true);
                addressRepository.save(firstAddress);
            }
        }
    }

    /**
     * Đặt địa chỉ mặc định cho người dùng
     */
    public Address setDefaultAddress(String userId, String addressId) {
        // Reset tất cả địa chỉ mặc định hiện tại
        resetDefaultAddresses(userId);
        
        // Đặt địa chỉ được chọn làm mặc định
        Address address = getAddressByIdAndUserId(addressId, userId);
        address.setDefault(true);
        return addressRepository.save(address);
    }

    /**
     * Lấy tất cả địa chỉ của người dùng
     */
    public List<Address> getUserAddresses(String userId) {
        return addressRepository.findByUserIdOrderByIsDefaultDesc(userId);
    }

    /**
     * Lấy địa chỉ mặc định của người dùng
     */
    public Optional<Address> getDefaultAddress(String userId) {
        return addressRepository.findByUserIdAndIsDefaultTrue(userId);
    }

    /**
     * Lấy địa chỉ theo ID và userId
     */
    public Address getAddressByIdAndUserId(String addressId, String userId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found with id: " + addressId));
        
        if (!address.getUserId().equals(userId)) {
            throw new RuntimeException("Address does not belong to the user");
        }
        
        return address;
    }

    /**
     * Reset tất cả địa chỉ mặc định của người dùng
     */
    private void resetDefaultAddresses(String userId) {
        List<Address> addresses = addressRepository.findByUserId(userId);
        for (Address address : addresses) {
            if (address.isDefault()) {
                address.setDefault(false);
                addressRepository.save(address);
            }
        }
    }
} 