package com.th26.usermanagement.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import com.th26.usermanagement.services.ModelService;

import java.math.BigDecimal;
import java.util.List;

@RestController
@Validated
@RequestMapping("/usermanagement/api/predict")
public class ModelController {
    private final ModelService modelService;
    public ModelController(ModelService modelService) {
        this.modelService = modelService;
    }

    @PostMapping("/{email:.+}")
    public ResponseEntity<String> queryModel(
        @PathVariable("email") 
        @Email(regexp="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,}$", flags=Pattern.Flag.CASE_INSENSITIVE) 
        String email,
        @RequestBody
        @Size(min=1)
        List<@DecimalMin(value="0.0") BigDecimal> inputData
    ) throws MethodArgumentNotValidException {
        return this.modelService.runInference(email, inputData);
    }
}
