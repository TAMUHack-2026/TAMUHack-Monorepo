package com.th26.usermanagement.dtos.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.DecimalMin;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ModelRerouteRequest {
    @NotNull
    @DecimalMin(value="0.0", inclusive = false)
    @JsonProperty("height_in")
    private BigDecimal height;

    @NotNull
    @DecimalMin(value="0.0", inclusive = false)
    @JsonProperty("weight_lbs")
    private BigDecimal weight;

    @NotBlank
    private String sex;

    @NotNull
    @JsonProperty("breath_data")
    private List<@DecimalMin(value="0.0", inclusive = false) BigDecimal> breathData;
}
