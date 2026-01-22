package com.th26.usermanagement.dtos.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class UserRequest {
    @NotBlank
    @Email(groups={CreateValidation.class, UpdateValidation.class}, regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,}$", flags = Pattern.Flag.CASE_INSENSITIVE)
    private String email;

    @NotBlank(groups=CreateValidation.class)
    private String password;

    @NotBlank(groups=CreateValidation.class)
    @JsonProperty("first_name")
    private String firstName;
    
    @NotBlank(groups=CreateValidation.class)
    @JsonProperty("last_name")
    private String lastName;
    
    @NotBlank(groups=CreateValidation.class)
    @Min(0)
    @Max(150)
    private Short age;

    @NotBlank(groups=CreateValidation.class)
    @Pattern(groups=CreateValidation.class, regexp = "^(male|female)$")
    private String sex;

    @JsonProperty("gender_identity")
    private String genderIdentity;

    @NotBlank(groups=CreateValidation.class)
    @JsonProperty("height_in")
    private BigDecimal height;

    @NotBlank(groups=CreateValidation.class)
    @JsonProperty("weight_lbs")
    private BigDecimal weight;
}
