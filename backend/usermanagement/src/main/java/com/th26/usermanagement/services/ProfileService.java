package com.th26.usermanagement.services;

import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.exceptions.UserNotFoundException;

public interface ProfileService {
    ProfileResponse getProfileByEmail(String email) throws UserNotFoundException;
}

