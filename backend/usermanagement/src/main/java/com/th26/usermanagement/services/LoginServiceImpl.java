package com.th26.usermanagement.services;


import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.th26.usermanagement.entities.User;
import com.th26.usermanagement.entities.Profile;
import com.th26.usermanagement.repositories.UserRepository;
import com.th26.usermanagement.repositories.ProfileRepository;
import com.th26.usermanagement.dtos.requests.UserRequest;
import com.th26.usermanagement.dtos.requests.LoginRequest;
import com.th26.usermanagement.exceptions.UserExistsException;
import com.th26.usermanagement.exceptions.UserNotFoundException;

@Service
public class LoginServiceImpl implements LoginService {
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;

    public LoginServiceImpl(UserRepository userRepository, ProfileRepository profileRepository) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
    }

    @Override
    @Transactional
    public void createUser(UserRequest request) throws UserExistsException {
        if (this.userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new UserExistsException("Conflict - User already exists");
        }

        Profile newUserProfile = Profile.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .age(request.getAge())
                .sex(request.getSex())
                .genderIdentity(request.getGenderIdentity())
                .height(request.getHeight())
                .weight(request.getWeight())
                .build();
        User newUser = User.builder()
                .email(request.getEmail())
                .passwordHash(request.getPassword())
                .build();

        // Since the Lombok builder doesn't call custom setters,
        // the profile-user relationship must be set manually.
        newUser.setProfile(newUserProfile);

        this.userRepository.save(newUser);
        this.profileRepository.save(newUserProfile);
    }

    @Override
    @Transactional
    public void updateUser(UserRequest request) {
        User toUpdate = this.userRepository.findByEmail(request.getEmail()).orElseThrow(() -> 
            new UserNotFoundException("Not found - user does not exist")
        );

        Profile toUpdateProfile = toUpdate.getProfile();

        if (request.getFirstName() != null) {
            toUpdateProfile.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            toUpdateProfile.setLastName(request.getLastName());
        }
        if (request.getAge() != null) {
            toUpdateProfile.setAge(request.getAge());
        }
        if (request.getSex() != null) {
            toUpdateProfile.setSex(request.getSex());
        }
        if (request.getGenderIdentity() != null) {
            toUpdateProfile.setGenderIdentity(request.getGenderIdentity());
        }
        if (request.getHeight() != null) {
            toUpdateProfile.setHeight(request.getHeight());
        }
        if (request.getWeight() != null) {
            toUpdateProfile.setWeight(request.getWeight());
        }
        
        this.profileRepository.save(toUpdateProfile);
    }

    @Override
    @Transactional
    public void deleteUserByEmail(String email) {
        User toDelete = this.userRepository.findByEmail(email).orElseThrow(() -> 
            new UserNotFoundException("Not found - user does not exist")
        );
        this.userRepository.delete(toDelete);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean validateCredentials(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null) {
            throw new UserNotFoundException("Not found - user does not exist");
        }
        return user.getPasswordHash().equals(request.getPassword());
    }
}
