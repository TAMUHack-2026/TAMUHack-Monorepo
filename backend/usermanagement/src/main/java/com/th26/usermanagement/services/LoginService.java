package com.th26.usermanagement.services;

import com.th26.usermanagement.dtos.requests.UserRequest;
import com.th26.usermanagement.dtos.requests.LoginRequest;
import com.th26.usermanagement.exceptions.UserExistsException;
import com.th26.usermanagement.exceptions.UserNotFoundException;

public interface LoginService {
    void createUser(UserRequest request) throws UserExistsException;
    void updateUser(UserRequest request) throws UserNotFoundException;
    void deleteUserByEmail(String email) throws UserNotFoundException;
    boolean validateCredentials(LoginRequest request);
}
