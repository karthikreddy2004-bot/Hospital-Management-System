package com.hms.hospital.service;

import com.hms.hospital.dto.AppointmentDto;
import com.hms.hospital.entity.Appointment;
import com.hms.hospital.entity.Doctor;
import com.hms.hospital.entity.Patient;
import com.hms.hospital.exception.ResourceNotFoundException;
import com.hms.hospital.repository.AppointmentRepository;
import com.hms.hospital.repository.DoctorRepository;
import com.hms.hospital.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AppointmentService {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private DoctorRepository doctorRepository;

    @Transactional(readOnly = true)
    public Page<Appointment> getAllAppointments(Pageable pageable) {
        return appointmentRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Page<Appointment> searchAppointments(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return appointmentRepository.findAll(pageable);
        }
        return appointmentRepository.search(keyword.trim(), pageable);
    }

    public Appointment getAppointmentById(Long id) {
        return appointmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Appointment not found with id: " + id));
    }

    @Transactional
    public Appointment createAppointment(AppointmentDto.Request request) {
        Patient patient = patientRepository.findById(request.getPatientId())
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + request.getPatientId()));
        Doctor doctor = doctorRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new ResourceNotFoundException("Doctor not found with id: " + request.getDoctorId()));

        Appointment appointment = new Appointment();
        appointment.setPatient(patient);
        appointment.setDoctor(doctor);
        appointment.setAppointmentDate(request.getAppointmentDate());
        appointment.setAppointmentTime(request.getAppointmentTime());
        appointment.setReason(request.getReason());
        appointment.setStatus(request.getStatus() != null ? request.getStatus() : Appointment.AppointmentStatus.SCHEDULED);

        return appointmentRepository.save(appointment);
    }

    @Transactional
    public Appointment updateAppointment(Long id, AppointmentDto.Request request) {
        Appointment existing = getAppointmentById(id);

        if (request.getPatientId() != null && !request.getPatientId().equals(existing.getPatient().getId())) {
            Patient patient = patientRepository.findById(request.getPatientId())
                    .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + request.getPatientId()));
            existing.setPatient(patient);
        }

        if (request.getDoctorId() != null && !request.getDoctorId().equals(existing.getDoctor().getId())) {
            Doctor doctor = doctorRepository.findById(request.getDoctorId())
                    .orElseThrow(() -> new ResourceNotFoundException("Doctor not found with id: " + request.getDoctorId()));
            existing.setDoctor(doctor);
        }

        existing.setAppointmentDate(request.getAppointmentDate());
        existing.setAppointmentTime(request.getAppointmentTime());
        existing.setReason(request.getReason());
        if (request.getStatus() != null) {
            existing.setStatus(request.getStatus());
        }

        return appointmentRepository.save(existing);
    }

    @Transactional
    public void deleteAppointment(Long id) {
        Appointment appointment = getAppointmentById(id);
        appointmentRepository.delete(appointment);
    }

    /** Maps entity -> flattened response DTO for clean React consumption */
    public AppointmentDto.Response mapToResponse(Appointment a) {
        AppointmentDto.Response dto = new AppointmentDto.Response();
        dto.setId(a.getId());
        dto.setPatientId(a.getPatient().getId());
        dto.setPatientName(a.getPatient().getName());
        dto.setDoctorId(a.getDoctor().getId());
        dto.setDoctorName(a.getDoctor().getName());
        dto.setDoctorSpecialization(a.getDoctor().getSpecialization());
        dto.setAppointmentDate(a.getAppointmentDate());
        dto.setAppointmentTime(a.getAppointmentTime());
        dto.setStatus(a.getStatus());
        dto.setReason(a.getReason());
        dto.setCreatedAt(a.getCreatedAt());
        return dto;
    }
}

