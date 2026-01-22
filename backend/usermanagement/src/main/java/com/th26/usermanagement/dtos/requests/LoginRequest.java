package com.th26.usermanagement.dtos.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;

import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank
    @Email(regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,}$", flags = Pattern.Flag.CASE_INSENSITIVE)
    private String email;

    @NotBlank
    private String password;
}
