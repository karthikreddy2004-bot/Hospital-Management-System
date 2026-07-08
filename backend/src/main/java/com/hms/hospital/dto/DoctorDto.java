package com.hms.hospital.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DoctorDto {

    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Specialization is required")
    private String specialization;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Phone is required")
    @Pattern(regexp = "^[0-9]{10}$", message = "Phone must be 10 digits")
    private String phone;

    private String qualification;

    @Min(value = 0, message = "Experience cannot be negative")
    private Integer experienceYears;

    @DecimalMin(value = "0.0", message = "Fee cannot be negative")
    private BigDecimal consultationFee;

    private Boolean available;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

