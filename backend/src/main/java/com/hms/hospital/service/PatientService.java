package com.hms.hospital.service;

import com.hms.hospital.dto.PatientDto;
import com.hms.hospital.entity.Patient;
import com.hms.hospital.exception.ResourceNotFoundException;
import com.hms.hospital.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PatientService {

    @Autowired
    private PatientRepository patientRepository;

    public Page<Patient> getAllPatients(Pageable pageable) {
        return patientRepository.findAll(pageable);
    }

    public Page<Patient> searchPatients(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return patientRepository.findAll(pageable);
        }
        return patientRepository.search(keyword.trim(), pageable);
    }

    public Patient getPatientById(Long id) {
        return patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + id));
    }

    @Transactional
    public Patient createPatient(PatientDto dto) {
        Patient patient = new Patient();
        mapDtoToEntity(dto, patient);
        return patientRepository.save(patient);
    }

    @Transactional
    public Patient updatePatient(Long id, PatientDto dto) {
        Patient existing = getPatientById(id);
        mapDtoToEntity(dto, existing);
        return patientRepository.save(existing);
    }

    @Transactional
    public void deletePatient(Long id) {
        Patient patient = getPatientById(id);
        patientRepository.delete(patient);
    }

    private void mapDtoToEntity(PatientDto dto, Patient patient) {
        patient.setName(dto.getName());
        patient.setAge(dto.getAge());
        patient.setGender(dto.getGender());
        patient.setEmail(dto.getEmail());
        patient.setPhone(dto.getPhone());
        patient.setAddress(dto.getAddress());
    }
}

