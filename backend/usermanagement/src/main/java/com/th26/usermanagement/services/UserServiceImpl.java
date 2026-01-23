package com.th26.usermanagement.services;

import com.th26.usermanagement.entities.User;
import com.th26.usermanagement.exceptions.UserNotFoundException;
import com.th26.usermanagement.entities.Profile;
import com.th26.usermanagement.dtos.responses.ProfileResponse;
import com.th26.usermanagement.repositories.UserRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public ProfileResponse getProfileByEmail(String email) throws UserNotFoundException {
        User user = this.userRepository.findByEmail(email).orElseThrow(() -> 
            new UserNotFoundException("Not found - user does not exist")
        );

        Profile profile = user.getProfile();
        ProfileResponse response = ProfileResponse.builder()
                .firstName(profile.getFirstName())
                .lastName(profile.getLastName())
                .age(profile.getAge())
                .sex(profile.getSex())
                .genderIdentity(profile.getGenderIdentity())
                .height(profile.getHeight())
                .weight(profile.getWeight())
                .build();
        return response;
    }
}
