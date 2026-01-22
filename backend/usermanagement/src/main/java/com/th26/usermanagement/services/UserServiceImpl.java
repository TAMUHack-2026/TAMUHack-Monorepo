package com.th26.usermanagement.services;

import com.th26.usermanagement.entities.User;
import com.th26.usermanagement.entities.Profile;
import com.th26.usermanagement.repositories.UserRepository;
import com.th26.usermanagement.repositories.ProfileRepository;
import com.th26.usermanagement.dtos.requests.UserRequest;

import org.springframework.stereotype.Service;

interface UserService {
    void createUser(UserRequest request);
    void updateUser(UserRequest request);
    User getUserByEmail(String email);
    boolean deleteUserByEmail(String email);
    Profile getProfileByEmail(String email);
}

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;

    public UserServiceImpl(UserRepository userRepository, ProfileRepository profileRepository) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
    }

    @Override
    public void createUser(UserRequest request) {
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
                .profile(newUserProfile)
                .build();
        userRepository.save(newUser);
        profileRepository.save(newUserProfile);
    }

    @Override
    public void updateUser(UserRequest request) {
        User toUpdate = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (toUpdate == null) {
            // TODO: Throw with proper exception
            return;
        }

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
        
        profileRepository.save(toUpdateProfile);
    }

    @Override
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }

    @Override
    public boolean deleteUserByEmail(String email) {
        User toDelete = userRepository.findByEmail(email).orElse(null);
        if (toDelete != null) {
            userRepository.delete(toDelete);
            return true;
        }
        return false;
    }

    @Override
    public Profile getProfileByEmail(String email) {
        User user = userRepository.findByEmail(email).orElse(null);
        if (user != null) {
            return user.getProfile();
        } else {
            return null;
        }
    }
}
