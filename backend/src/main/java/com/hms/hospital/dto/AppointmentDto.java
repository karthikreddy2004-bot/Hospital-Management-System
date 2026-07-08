package com.hms.hospital.dto;

import com.hms.hospital.entity.Appointment;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class AppointmentDto {

    /** Used for create/update requests */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Request {
        @NotNull(message = "Patient id is required")
        private Long patientId;

        @NotNull(message = "Doctor id is required")
        private Long doctorId;

        @NotNull(message = "Appointment date is required")
        private LocalDate appointmentDate;

        @NotNull(message = "Appointment time is required")
        private LocalTime appointmentTime;

        private String reason;

        private Appointment.AppointmentStatus status;
    }

    /** Used for responses - flattened with patient/doctor names for easy display in React */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private Long id;
        private Long patientId;
        private String patientName;
        private Long doctorId;
        private String doctorName;
        private String doctorSpecialization;
        private LocalDate appointmentDate;
        private LocalTime appointmentTime;
        private Appointment.AppointmentStatus status;
        private String reason;
        private LocalDateTime createdAt;
    }
}

