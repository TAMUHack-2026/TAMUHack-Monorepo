package com.th26.usermanagement.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.client.RestClient;

import com.th26.usermanagement.dtos.requests.ModelRerouteRequest;
import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.exceptions.GatewayException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class ModelServiceImpl implements ModelService {
    private final ProfileService profileService;
    private final RestClient restClient;

    public ModelServiceImpl(ProfileService profileService, @Value("${com.th26.model.endpoint}") String modelEndpoint) {
        this.profileService = profileService;
        this.restClient = RestClient.create(modelEndpoint);
    }
    @Override
    public ResponseEntity<String> runInference(String email, List<BigDecimal> inputData) throws MethodArgumentNotValidException {
        ProfileResponse userProfile = this.profileService.getProfileByEmail(email);
        ModelRerouteRequest modelRequest = ModelRerouteRequest.builder()
            .height(userProfile.getHeight())
            .weight(userProfile.getWeight())
            .sex(userProfile.getSex())
            .breathData(inputData)
            .build();

        ResponseEntity<String> response = this.restClient.post()
            .uri("/predict")
            .body(modelRequest)
            .retrieve()
            .toEntity(String.class);

        if (response.getStatusCode() == HttpStatus.UNPROCESSABLE_CONTENT) {
            throw new MethodArgumentNotValidException(null, null);
        } else if (response.getStatusCode() == HttpStatus.INTERNAL_SERVER_ERROR) {
            throw new GatewayException("Model service encountered an internal error");
        } else if (response.getStatusCode() == HttpStatus.SERVICE_UNAVAILABLE) {
            throw new GatewayException("Model service is currently unavailable");
        } else {
            return response;
        }
    }
}
