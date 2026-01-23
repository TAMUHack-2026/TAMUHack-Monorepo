package com.th26.usermanagement.dtos.responses;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileResponse {
    @NotBlank
    @JsonProperty("first_name")
    private String firstName;

    @NotBlank
    @JsonProperty("last_name")
    private String lastName;

    @NotNull
    @Min(0)
    @Max(150)
    private Short age;

    @NotBlank
    @Pattern(regexp = "^(male|female)$")
    private String sex;

    @JsonProperty("gender_identity")
    private String genderIdentity;

    @NotNull
    @JsonProperty("height_in")
    private BigDecimal height;

    @NotNull
    @JsonProperty("weight_lbs")
    private BigDecimal weight;
}
