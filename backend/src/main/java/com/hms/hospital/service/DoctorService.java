package com.hms.hospital.service;

import com.hms.hospital.dto.DoctorDto;
import com.hms.hospital.entity.Doctor;
import com.hms.hospital.exception.DuplicateResourceException;
import com.hms.hospital.exception.ResourceNotFoundException;
import com.hms.hospital.repository.DoctorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DoctorService {

    @Autowired
    private DoctorRepository doctorRepository;

    public Page<Doctor> getAllDoctors(Pageable pageable) {
        return doctorRepository.findAll(pageable);
    }

    public Page<Doctor> searchDoctors(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return doctorRepository.findAll(pageable);
        }
        return doctorRepository.search(keyword.trim(), pageable);
    }

    public Doctor getDoctorById(Long id) {
        return doctorRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found with id: " + id));
    }

    @Transactional
    public Doctor createDoctor(DoctorDto dto) {
        if (doctorRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("A doctor with this email already exists");
        }
        Doctor doctor = mapToEntity(dto);
        return doctorRepository.save(doctor);
    }

    @Transactional
    public Doctor updateDoctor(Long id, DoctorDto dto) {
        Doctor existing = getDoctorById(id);

        // If email changed, ensure uniqueness
        if (!existing.getEmail().equalsIgnoreCase(dto.getEmail()) && doctorRepository.existsByEmail(dto.getEmail())) {
            throw new DuplicateResourceException("A doctor with this email already exists");
        }

        existing.setName(dto.getName());
        existing.setSpecialization(dto.getSpecialization());
        existing.setEmail(dto.getEmail());
        existing.setPhone(dto.getPhone());
        existing.setQualification(dto.getQualification());
        existing.setExperienceYears(dto.getExperienceYears() != null ? dto.getExperienceYears() : 0);
        existing.setConsultationFee(dto.getConsultationFee());
        existing.setAvailable(dto.getAvailable() != null ? dto.getAvailable() : existing.getAvailable());

        return doctorRepository.save(existing);
    }

    @Transactional
    public void deleteDoctor(Long id) {
        Doctor doctor = getDoctorById(id);
        doctorRepository.delete(doctor);
    }

    private Doctor mapToEntity(DoctorDto dto) {
        Doctor doctor = new Doctor();
        doctor.setName(dto.getName());
        doctor.setSpecialization(dto.getSpecialization());
        doctor.setEmail(dto.getEmail());
        doctor.setPhone(dto.getPhone());
        doctor.setQualification(dto.getQualification());
        doctor.setExperienceYears(dto.getExperienceYears() != null ? dto.getExperienceYears() : 0);
        doctor.setConsultationFee(dto.getConsultationFee());
        doctor.setAvailable(dto.getAvailable() != null ? dto.getAvailable() : true);
        return doctor;
    }
}

