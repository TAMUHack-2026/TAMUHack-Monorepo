package com.th26.usermanagement.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.client.RestClient;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;

import com.th26.usermanagement.services.ProfileService;
import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.dtos.requests.ModelRerouteRequest;

import java.math.BigDecimal;
import java.util.List;

@RestController
@Validated
@RequestMapping("/usermanagement/api/predict")
public class ModelController {
    private ProfileService profileService;
    private RestClient restClient;

    public ModelController(ProfileService profileService, @Value("${com.th26.model.endpoint}") String modelEndpoint) {
        this.profileService = profileService;
        this.restClient = RestClient.create(modelEndpoint);
    }

    @PostMapping("/{email:.+}")
    public ResponseEntity<String> queryModel(
        @PathVariable("email") 
        @Email(regexp = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,}$", flags = Pattern.Flag.CASE_INSENSITIVE) 
        String email,
        @RequestBody List<BigDecimal> inputData
    ) {
        ProfileResponse userProfile = this.profileService.getProfileByEmail(email);
        ModelRerouteRequest modelRequest = ModelRerouteRequest.builder()
            .height(userProfile.getHeight())
            .weight(userProfile.getWeight())
            .sex(userProfile.getSex())
            .breathData(inputData)
            .build();

        return this.restClient.post()
            .uri("/predict")
            .body(modelRequest)
            .retrieve()
            .toEntity(String.class);
    }
}
