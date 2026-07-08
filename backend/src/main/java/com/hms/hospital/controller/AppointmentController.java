package com.hms.hospital.controller;

import com.hms.hospital.dto.AppointmentDto;
import com.hms.hospital.entity.Appointment;
import com.hms.hospital.service.AppointmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {

    @Autowired
    private AppointmentService appointmentService;

    // GET /api/appointments?page=0&size=10&sortBy=appointmentDate&direction=desc&keyword=john
    @GetMapping
    public ResponseEntity<Page<AppointmentDto.Response>> getAllAppointments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "desc") String direction,
            @RequestParam(required = false) String keyword) {

        Sort sort = direction.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<Appointment> result = (keyword != null && !keyword.trim().isEmpty())
                ? appointmentService.searchAppointments(keyword, pageable)
                : appointmentService.getAllAppointments(pageable);

        Page<AppointmentDto.Response> response = result.map(appointmentService::mapToResponse);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppointmentDto.Response> getAppointmentById(@PathVariable Long id) {
        Appointment appointment = appointmentService.getAppointmentById(id);
        return ResponseEntity.ok(appointmentService.mapToResponse(appointment));
    }

    @PostMapping
    public ResponseEntity<AppointmentDto.Response> createAppointment(@Valid @RequestBody AppointmentDto.Request request) {
        Appointment created = appointmentService.createAppointment(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(appointmentService.mapToResponse(created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppointmentDto.Response> updateAppointment(@PathVariable Long id, @Valid @RequestBody AppointmentDto.Request request) {
        Appointment updated = appointmentService.updateAppointment(id, request);
        return ResponseEntity.ok(appointmentService.mapToResponse(updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAppointment(@PathVariable Long id) {
        appointmentService.deleteAppointment(id);
        return ResponseEntity.noContent().build();
    }
}

