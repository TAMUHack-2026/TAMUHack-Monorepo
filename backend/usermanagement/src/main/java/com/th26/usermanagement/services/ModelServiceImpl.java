package com.th26.usermanagement.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.th26.usermanagement.dtos.requests.ModelRerouteRequest;
import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.exceptions.GatewayException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class ModelServiceImpl implements ModelService {
    private final ProfileService profileService;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final String modelEndpoint;

    public ModelServiceImpl(ProfileService profileService, @Value("${com.th26.model.endpoint}") String modelEndpoint) {
        this.modelEndpoint = modelEndpoint;
        this.profileService = profileService;
        this.restTemplate = new RestTemplate();
    }
    @Override
    public ResponseEntity<String> runInference(String email, List<BigDecimal> inputData) throws MethodArgumentNotValidException {
        ProfileResponse userProfile = this.profileService.getProfileByEmail(email);
        ModelRerouteRequest modelRequest = ModelRerouteRequest.builder()
            .height(userProfile.getHeight())
            .weight(userProfile.getWeight())
            .sex(userProfile.getSex().toLowerCase())
            .breathData(inputData)
            .build();

        try {
            String jsonBody = this.objectMapper.writeValueAsString(modelRequest);
            System.out.println("Sending request to model service: " + jsonBody);

//            ResponseEntity<String> response = this.restTemplate.post()
//                .uri("/predict")
//                .contentType(MediaType.APPLICATION_JSON)
//                .accept(MediaType.APPLICATION_JSON)
//                .body(jsonBody)
//                .retrieve()
//                .toEntity(String.class);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<ModelRerouteRequest> entity = new HttpEntity<>(modelRequest, headers);
            ResponseEntity<String> response = this.restTemplate.postForEntity(
                this.modelEndpoint + "/predict",
                entity,
                String.class
            );

            return response;
        } catch (RestClientResponseException e) {
            System.err.println("Model service error: " + e.getResponseBodyAsString());
            throw new GatewayException("Error communicating with model service");
        } catch (JsonProcessingException e) {
            System.err.println("JSON processing error: " + e.getMessage());
            throw new GatewayException("Error processing request data");
        }

    }
}
